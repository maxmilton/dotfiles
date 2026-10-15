import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from yt_dlp import YoutubeDL
from yt_dlp.extractor.youtube import YoutubeIE
from yt_dlp.postprocessor.ffmpeg import FFmpegEmbedSubtitlePP

from yt_dlp_plugins.extractor.smart_subs import (
    _manual_track,
    _native_lang,
    _original_auto_track,
    _select_tracks,
    _SmartSubsYoutubeIE,
    _translation_track,
)


def _track(name):
    return [{"ext": "vtt", "name": name, "url": f"https://example.com/{name}"}]


class TrackSelectionTest(unittest.TestCase):
    def test_manual_track_prefers_exact_then_deterministic_variant(self):
        self.assertEqual(
            _manual_track({"en-GB": [], "en": [], "en-US": []}, "en"), "en"
        )
        self.assertEqual(_manual_track({"en-US": [], "en-GB": []}, "en"), "en-GB")
        self.assertIsNone(_manual_track({"eng": [], "ko": []}, "en"))

    def test_original_auto_track_accepts_regional_keys(self):
        auto = {"en-US-orig": [], "en-GB-orig": []}

        self.assertEqual(_original_auto_track(auto, "en"), "en-GB-orig")
        self.assertEqual(
            _original_auto_track({**auto, "en-orig": []}, "en"),
            "en-orig",
        )
        self.assertIsNone(_original_auto_track({"ko-orig": []}, "en"))

    def test_translation_prefers_exact_manual_source(self):
        manual = {"ko-KR": [], "ko": []}
        auto = {"en-ko-KR": [], "en-ko": [], "en": []}

        self.assertEqual(
            _translation_track(auto, manual, "en", "ko"),
            ("en-ko", "manual", "ko"),
        )

    def test_translation_variant_choice_is_deterministic(self):
        manual = {"ko-ZZ": [], "ko-AA": []}
        auto = {"en-ko-ZZ": [], "en-ko-AA": [], "en": []}

        self.assertEqual(
            _translation_track(auto, manual, "en", "ko"),
            ("en-ko-AA", "manual", "ko-AA"),
        )

    def test_asr_translation_requires_matching_original_track(self):
        auto = {"ko-orig": [], "en": []}

        self.assertEqual(
            _translation_track(auto, {}, "en", "ko"),
            ("en", "ASR", "ko-orig"),
        )
        self.assertIsNone(_translation_track({"en": []}, {}, "en", "ko"))
        self.assertIsNone(_translation_track({}, {}, "en", "ko"))

    def test_translation_prefers_exact_regional_native_source(self):
        manual = {"zh-Hans": [], "zh-Hant": []}
        auto = {"en-zh-Hans": [], "en-zh-Hant": []}

        self.assertEqual(
            _translation_track(auto, manual, "en", "zh-Hant"),
            ("en-zh-Hant", "manual", "zh-Hant"),
        )


class NativeLanguageTest(unittest.TestCase):
    def test_original_captions_are_primary_evidence(self):
        info = {
            "formats": [{
                "acodec": "opus",
                "language": "ko",
                "language_preference": 10,
            }],
        }

        native, source = _native_lang(info, {"en-US-orig": []})

        self.assertEqual(native, "en-US")
        self.assertIn("en-US-orig", source)

    def test_marked_original_audio_resolves_dubbed_video(self):
        info = {
            "formats": [
                {"acodec": "opus", "language": "en", "language_preference": -1},
                {"acodec": "opus", "language": "ko", "language_preference": 10},
            ],
        }

        self.assertEqual(_native_lang(info, {})[0], "ko")

    def test_marked_audio_resolves_ambiguous_original_captions(self):
        info = {
            "formats": [{
                "acodec": "opus",
                "language": "ko-KR",
                "language_preference": 10,
            }],
        }

        self.assertEqual(
            _native_lang(info, {"en-orig": [], "ko-orig": []})[0],
            "ko-KR",
        )

    def test_single_audio_language_is_final_fallback(self):
        info = {
            "formats": [
                {"acodec": "opus", "language": "en-US"},
                {"acodec": "none", "language": "ko"},
            ],
        }

        self.assertEqual(_native_lang(info, {})[0], "en-US")

    def test_ambiguous_or_missing_audio_returns_unknown(self):
        dubbed = {
            "formats": [
                {"acodec": "opus", "language": "en"},
                {"acodec": "opus", "language": "ko"},
            ],
        }

        self.assertIsNone(_native_lang(dubbed, {})[0])
        self.assertIsNone(_native_lang({}, {})[0])


class FullSelectionTest(unittest.TestCase):
    def test_english_asr_selects_original_and_korean_translation(self):
        info = {
            "automatic_captions": {
                "en-US-orig": _track("en original"),
                "en": _track("en compatibility"),
                "ko": _track("ko from English ASR"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(manual, {})
        self.assertEqual(native, "en-US")
        self.assertEqual(
            auto["en"][0]["name"], "English [original ASR (en-US-orig)]"
        )
        self.assertEqual(
            auto["ko"][0]["name"],
            "Korean [auto-translated native ASR (en-US-orig)]",
        )
        self.assertEqual(
            info["automatic_captions"]["en-US-orig"][0]["name"], "en original"
        )
        self.assertIn("ASR", decisions["ko"])

    def test_korean_manual_source_is_used_for_english_translation(self):
        info = {
            "formats": [{
                "acodec": "opus",
                "language": "ko",
                "language_preference": 10,
            }],
            "subtitles": {"ko-KR": _track("manual Korean")},
            "automatic_captions": {
                "en-ko-KR": _track("English from manual Korean"),
                "en": _track("English from Korean ASR"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "ko")
        self.assertEqual(set(manual), {"ko"})
        self.assertEqual(set(auto), {"en"})
        self.assertEqual(
            auto["en"][0]["name"],
            "English [auto-translated native uploader captions (ko-KR)]",
        )
        self.assertIn("en-ko-KR", decisions["en"])
        self.assertIn("uploader captions", decisions["en"])

    def test_manual_target_captions_override_automatic_tracks(self):
        info = {
            "subtitles": {
                "en-GB": _track("manual English"),
                "ko": _track("manual Korean"),
            },
            "automatic_captions": {
                "en-orig": _track("automatic English"),
                "ko": _track("automatic Korean"),
            },
        }

        manual, auto, _, _, _ = _select_tracks(info)

        self.assertEqual(set(manual), {"en", "ko"})
        self.assertEqual(auto, {})
        self.assertEqual(
            manual["en"][0]["name"], "English [uploader captions (en-GB)]"
        )

    def test_third_language_asr_translates_both_targets(self):
        info = {
            "automatic_captions": {
                "ja-orig": _track("Japanese original"),
                "en": _track("English from Japanese ASR"),
                "ko": _track("Korean from Japanese ASR"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "ja")
        self.assertEqual(manual, {})
        self.assertEqual(set(auto), {"en", "ko"})
        self.assertIn("ASR ja-orig", decisions["en"])
        self.assertIn("ASR ja-orig", decisions["ko"])

    def test_third_language_manual_source_fills_only_missing_target(self):
        info = {
            "formats": [{
                "acodec": "opus",
                "language": "fr-FR",
                "language_preference": 10,
            }],
            "subtitles": {
                "en": _track("manual English"),
                "fr-FR": _track("manual French"),
            },
            "automatic_captions": {
                "en-fr-FR": _track("English from manual French"),
                "ko-fr-FR": _track("Korean from manual French"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "fr-FR")
        self.assertEqual(set(manual), {"en"})
        self.assertEqual(set(auto), {"ko"})
        self.assertIn("uploader captions fr-FR", decisions["ko"])

    def test_third_language_manual_source_is_preferred_over_asr(self):
        info = {
            "subtitles": {"fr": _track("manual French")},
            "automatic_captions": {
                "fr-orig": _track("French ASR"),
                "en-fr": _track("English from manual French"),
                "ko-fr": _track("Korean from manual French"),
                "en": _track("English from French ASR"),
                "ko": _track("Korean from French ASR"),
            },
        }

        _, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "fr")
        self.assertEqual(
            auto["en"][0]["url"], info["automatic_captions"]["en-fr"][0]["url"]
        )
        self.assertEqual(
            auto["ko"][0]["url"], info["automatic_captions"]["ko-fr"][0]["url"]
        )
        self.assertEqual(
            auto["en"][0]["name"],
            "English [auto-translated native uploader captions (fr)]",
        )
        self.assertEqual(
            auto["ko"][0]["name"],
            "Korean [auto-translated native uploader captions (fr)]",
        )
        self.assertIn("uploader captions fr", decisions["en"])
        self.assertIn("uploader captions fr", decisions["ko"])

    def test_third_language_without_native_caption_keeps_manual_targets_only(self):
        info = {
            "formats": [{
                "acodec": "opus",
                "language": "ja",
                "language_preference": 10,
            }],
            "subtitles": {"en": _track("manual English")},
            "automatic_captions": {
                "en": _track("translated English"),
                "ko": _track("translated Korean"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "ja")
        self.assertEqual(set(manual), {"en"})
        self.assertEqual(auto, {})
        self.assertEqual(decisions["ko"], "none")

    def test_third_language_unavailable_translation_is_omitted(self):
        info = {
            "automatic_captions": {
                "fr-orig": _track("French original"),
                "en": _track("English translation"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "fr")
        self.assertEqual(manual, {})
        self.assertEqual(set(auto), {"en"})
        self.assertEqual(decisions["ko"], "none")

    def test_unknown_native_language_keeps_manual_targets_only(self):
        info = {
            "subtitles": {"ko": _track("manual Korean")},
            "automatic_captions": {"en": _track("automatic English")},
        }

        manual, auto, native, _, _ = _select_tracks(info)

        self.assertIsNone(native)
        self.assertEqual(set(manual), {"ko"})
        self.assertEqual(auto, {})

    def test_unknown_native_language_uses_manual_source_translation(self):
        info = {
            "subtitles": {"fr": _track("manual French")},
            "automatic_captions": {"en-fr": _track("English from manual French")},
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertIsNone(native)
        self.assertEqual(manual, {})
        self.assertEqual(
            auto["en"][0]["name"],
            "English [auto-translated uploader captions (fr)]",
        )
        self.assertIn("unconfirmed uploader captions fr", decisions["en"])
        self.assertEqual(decisions["ko"], "none")

    def test_unknown_native_language_uses_lexical_manual_source_order(self):
        info = {
            "subtitles": {
                "fr": _track("manual French"),
                "ko": _track("manual Korean"),
            },
            "automatic_captions": {
                "en-fr": _track("English from manual French"),
                "en-ko": _track("English from manual Korean"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertIsNone(native)
        self.assertEqual(set(manual), {"ko"})
        self.assertEqual(
            auto["en"][0]["name"],
            "English [auto-translated uploader captions (fr)]",
        )
        self.assertIn("unconfirmed uploader captions fr", decisions["en"])

    def test_known_native_language_does_not_use_unconfirmed_translation(self):
        info = {
            "subtitles": {"fr": _track("manual French")},
            "automatic_captions": {
                "ja-orig": _track("Japanese original"),
                "en-fr": _track("English from manual French"),
            },
        }

        manual, auto, native, _, decisions = _select_tracks(info)

        self.assertEqual(native, "ja")
        self.assertEqual(manual, {})
        self.assertEqual(auto, {})
        self.assertEqual(decisions, {"en": "none", "ko": "none"})

    def test_empty_input_produces_empty_output(self):
        manual, auto, native, _, decisions = _select_tracks({})

        self.assertEqual(manual, {})
        self.assertEqual(auto, {})
        self.assertIsNone(native)
        self.assertEqual(decisions, {"en": "none", "ko": "none"})

    def test_labels_every_format_without_mutating_source_tracks(self):
        tracks = [
            {"ext": "srv1", "name": "English", "url": "https://example.com/srv1"},
            {"ext": "vtt", "name": "English", "url": "https://example.com/vtt"},
        ]

        manual, _, _, _, _ = _select_tracks({"subtitles": {"en": tracks}})

        self.assertEqual(
            [track["name"] for track in manual["en"]],
            [
                "English [uploader captions (en)]",
                "English [uploader captions (en)]",
            ],
        )
        self.assertEqual([track["name"] for track in tracks], ["English", "English"])

    def test_each_target_appears_in_at_most_one_output(self):
        cases = [
            {},
            {"subtitles": {"en": _track("manual English")}},
            {
                "automatic_captions": {
                    "ko-orig": _track("Korean original"),
                    "en": _track("English translation"),
                },
            },
            {
                "automatic_captions": {
                    "fr-orig": _track("French original"),
                    "en": _track("English translation"),
                    "ko": _track("Korean translation"),
                },
            },
        ]

        for info in cases:
            with self.subTest(info=info):
                manual, auto, _, _, _ = _select_tracks(info)
                self.assertLessEqual(set(manual), {"en", "ko"})
                self.assertLessEqual(set(auto), {"en", "ko"})
                self.assertTrue(set(manual).isdisjoint(auto))


class YtDlpIntegrationTest(unittest.TestCase):
    def test_extractor_adapter_filters_superclass_result_and_logs_decisions(self):
        info = {
            "id": "video-id",
            "title": "Unrelated metadata",
            "automatic_captions": {
                "en-orig": _track("English original"),
                "ko": _track("Korean translation"),
                "fr": _track("French translation"),
            },
        }
        extractor = _SmartSubsYoutubeIE()

        with (
            patch.object(YoutubeIE, "_real_extract", return_value=info),
            patch.object(extractor, "write_debug") as write_debug,
        ):
            result = extractor._real_extract("https://youtu.be/video-id")

        self.assertEqual(result["title"], "Unrelated metadata")
        self.assertEqual(result["subtitles"], {})
        self.assertEqual(set(result["automatic_captions"]), {"en", "ko"})
        messages = [call.args[0] for call in write_debug.call_args_list]
        self.assertTrue(any("native language: en" in message for message in messages))
        self.assertTrue(
            any("ko: automatic translation" in message for message in messages)
        )

    def test_process_subtitles_receives_only_exact_wrapper_languages(self):
        info = {
            "subtitles": {"en-US": _track("manual English")},
            "automatic_captions": {
                "ko-orig": _track("Korean original"),
                "en-ko": _track("English from manual Korean"),
            },
            "formats": [{
                "acodec": "opus",
                "language": "ko",
                "language_preference": 10,
            }],
        }
        manual, auto, _, _, _ = _select_tracks(info)
        ydl = YoutubeDL({
            "quiet": True,
            "subtitlesformat": "vtt/best",
            "subtitleslangs": ["en", "ko"],
            "writeautomaticsub": True,
            "writesubtitles": True,
        })

        requested = ydl.process_subtitles("video-id", manual, auto)

        self.assertEqual(set(requested), {"en", "ko"})
        self.assertEqual(
            requested["en"]["name"], "English [uploader captions (en-US)]"
        )
        self.assertEqual(
            requested["ko"]["name"], "Korean [original ASR (ko-orig)]"
        )


@unittest.skipUnless(
    shutil.which("ffmpeg") and shutil.which("ffprobe"),
    "ffmpeg and ffprobe are required",
)
class EmbeddedSubtitleTest(unittest.TestCase):
    def test_embedded_title_and_handler_name_preserve_provenance(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            video = directory / "video.mkv"
            subtitle = directory / "subtitle.vtt"
            subtitle.write_text(
                "WEBVTT\\n\\n00:00.000 --> 00:01.000\\nHello\\n",
                encoding="utf-8",
            )
            subprocess.run(
                [
                    shutil.which("ffmpeg"),
                    "-f", "lavfi",
                    "-i", "color=c=black:s=16x16:r=1",
                    "-t", "1",
                    "-c:v", "ffv1",
                    "-y",
                    str(video),
                ],
                check=True,
                capture_output=True,
            )

            name = "English [uploader captions (en)]"
            FFmpegEmbedSubtitlePP(YoutubeDL({"quiet": True})).run({
                "ext": "mkv",
                "filepath": str(video),
                "requested_subtitles": {
                    "en": {"ext": "vtt", "filepath": str(subtitle), "name": name},
                },
            })
            result = subprocess.run(
                [
                    shutil.which("ffprobe"),
                    "-v", "error",
                    "-select_streams", "s",
                    "-show_entries", "stream_tags=language,title,handler_name",
                    "-of", "json",
                    str(video),
                ],
                check=True,
                capture_output=True,
                text=True,
            )

        tags = json.loads(result.stdout)["streams"][0]["tags"]
        self.assertEqual(tags["language"], "eng")
        self.assertEqual(tags["title"], name)
        self.assertEqual(tags["HANDLER_NAME"], name)


class LiveYoutubeTest(unittest.TestCase):
    def _extract(self, url):
        yt_dlp = shutil.which("yt-dlp")
        self.assertIsNotNone(yt_dlp, "yt-dlp executable not found")
        plugin_root = Path(__file__).resolve().parents[1]
        result = subprocess.run(
            [
                yt_dlp,
                "--ignore-config",
                "--plugin-dirs",
                str(plugin_root),
                "--verbose",
                "--write-subs",
                "--write-auto-subs",
                "--sub-langs",
                "en,ko",
                "--dump-single-json",
                url,
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        self.assertIn("Extractor Plugins: smart-subs (YoutubeIE)", result.stderr)
        return json.loads(result.stdout)

    def _assert_bilingual_output(self, info):
        manual = set(info.get("subtitles") or {})
        auto = set(info.get("automatic_captions") or {})

        self.assertLessEqual(manual, {"en", "ko"})
        self.assertLessEqual(auto, {"en", "ko"})
        self.assertTrue(manual.isdisjoint(auto))
        self.assertEqual(manual | auto, {"en", "ko"})

    @unittest.skipUnless(
        os.environ.get("SMART_SUBS_EN_URL"),
        "set SMART_SUBS_EN_URL to run this live test",
    )
    def test_english_native_video(self):
        self._assert_bilingual_output(self._extract(os.environ["SMART_SUBS_EN_URL"]))

    @unittest.skipUnless(
        os.environ.get("SMART_SUBS_KO_URL"),
        "set SMART_SUBS_KO_URL to run this live test",
    )
    def test_korean_native_video(self):
        self._assert_bilingual_output(self._extract(os.environ["SMART_SUBS_KO_URL"]))

    @unittest.skipUnless(
        os.environ.get("SMART_SUBS_OTHER_URL"),
        "set SMART_SUBS_OTHER_URL to run this live test",
    )
    def test_other_native_video(self):
        self._assert_bilingual_output(
            self._extract(os.environ["SMART_SUBS_OTHER_URL"])
        )


if __name__ == "__main__":
    unittest.main()
