from yt_dlp.extractor.youtube import YoutubeIE

_LANGS = ("en", "ko")
_LANG_NAMES = {"en": "English", "ko": "Korean"}
_ORIGINAL_LANGUAGE_PREFERENCE = 10


def _base_lang(lang):
    return lang.split("-", 1)[0]


def _language_tracks(tracks, lang):
    return sorted(
        (key for key in tracks if key == lang or key.startswith(f"{lang}-")),
        key=lambda key: (key != lang, len(key), key),
    )


def _manual_track(subs, lang):
    return next(iter(_language_tracks(subs, lang)), None)


def _original_auto_track(auto, lang):
    base = _base_lang(lang)
    candidates = [
        key
        for key in auto
        if key.endswith("-orig") and _base_lang(key.removesuffix("-orig")) == base
    ]
    return min(
        candidates,
        key=lambda key: (
            key != f"{lang}-orig",
            key != f"{base}-orig",
            len(key),
            key,
        ),
        default=None,
    )


def _unambiguous_lang(langs):
    if len(langs) == 1:
        return next(iter(langs))

    bases = {_base_lang(lang) for lang in langs}
    return next(iter(bases)) if len(bases) == 1 else None


def _native_lang(info, auto):
    # YouTube explicitly labels original automatic captions with "-orig".
    original_keys = sorted(key for key in auto if key.endswith("-orig"))
    native = _unambiguous_lang({key.removesuffix("-orig") for key in original_keys})
    if native:
        return native, f"original captions: {', '.join(original_keys)}"

    # YouTube marks original audio more strongly than dubbed/default audio.
    original_audio = _unambiguous_lang(
        {
            fmt["language"]
            for fmt in info.get("formats", ())
            if fmt.get("acodec") != "none"
            and fmt.get("language")
            and fmt.get("language_preference") == _ORIGINAL_LANGUAGE_PREFERENCE
        },
    )
    if original_audio:
        return original_audio, "audio marked original"

    # YouTube also propagates the detected original-caption language onto
    # audio formats where possible.
    audio = _unambiguous_lang(
        {
            fmt["language"]
            for fmt in info.get("formats", ())
            if fmt.get("acodec") != "none" and fmt.get("language")
        },
    )
    if audio:
        return audio, "only audio language"

    return None, "no unambiguous original-caption or audio language"


def _source_manual_tracks(manual, lang):
    candidates = _language_tracks(manual, lang)
    base = _base_lang(lang)
    if base != lang:
        candidates.extend(
            key for key in _language_tracks(manual, base) if key not in candidates
        )
    return candidates


def _label_tracks(tracks, dst, provenance):
    return [
        {
            **track,
            "name": f"{_LANG_NAMES[dst]} [{provenance}]",
        }
        for track in tracks
    ]


def _translation_track(auto, manual, dst, src):
    # Prefer translating uploader-provided source captions.
    for src_key in _source_manual_tracks(manual, src):
        if (key := f"{dst}-{src_key}") in auto:
            return key, "manual", src_key

    # ASR translations use the target language directly, but only trust one
    # when the matching original ASR source is also present.
    if (src_key := _original_auto_track(auto, src)) and dst in auto:
        return dst, "ASR", src_key

    return None


def _unconfirmed_translation_track(auto, manual, dst):
    candidates = [
        src_key
        for src_key in manual
        if _base_lang(src_key) != dst and f"{dst}-{src_key}" in auto
    ]
    if src_key := min(candidates, default=None):
        return f"{dst}-{src_key}", src_key

    return None


def _select_tracks(info):
    manual = info.get("subtitles") or {}
    auto = info.get("automatic_captions") or {}
    native, native_source = _native_lang(info, auto)

    selected_manual = {}
    selected_auto = {}
    decisions = {}
    native_base = _base_lang(native) if native else None

    for dst in _LANGS:
        # 1. Uploader-provided target-language captions.
        if key := _manual_track(manual, dst):
            selected_manual[dst] = _label_tracks(
                manual[key],
                dst,
                f"uploader captions ({key})",
            )
            decisions[dst] = f"uploader captions {key}"
            continue

        # 2. Original automatic captions.
        if native_base == dst:
            key = _original_auto_track(auto, dst)
            if key is None and dst in auto:
                key = dst
            if key is not None:
                selected_auto[dst] = _label_tracks(
                    auto[key],
                    dst,
                    f"original ASR ({key})",
                )
                decisions[dst] = f"original automatic captions {key}"
                continue

        # 3. Translate from the confirmed native caption source.
        if native and native_base != dst:
            if translation := _translation_track(auto, manual, dst, native):
                key, source_kind, source_key = translation
                if source_kind == "manual":
                    label = f"auto-translated native uploader captions ({source_key})"
                    source = f"uploader captions {source_key}"
                else:
                    label = f"auto-translated native ASR ({source_key})"
                    source = f"ASR {source_key}"
                selected_auto[dst] = _label_tracks(auto[key], dst, label)
                decisions[dst] = f"automatic translation {key} from {source}"
                continue

        # 4. Fall back to an uploader-caption translation without native proof.
        if native is None:
            if translation := _unconfirmed_translation_track(auto, manual, dst):
                key, source_key = translation
                selected_auto[dst] = _label_tracks(
                    auto[key],
                    dst,
                    f"auto-translated uploader captions ({source_key})",
                )
                decisions[dst] = (
                    f"automatic translation {key} from unconfirmed uploader captions {source_key}"  # noqa: E501
                )
                continue

        decisions[dst] = "none"

    return selected_manual, selected_auto, native, native_source, decisions


class _SmartSubsYoutubeIE(YoutubeIE, plugin_name="smart-subs"):
    def _real_extract(self, url):
        info = super()._real_extract(url)

        selected_manual, selected_auto, native, native_source, decisions = (
            _select_tracks(info)
        )

        info["subtitles"] = selected_manual
        info["automatic_captions"] = selected_auto

        self.write_debug(
            f"[smart-subs] native language: {native or 'unknown'} ({native_source})",
        )
        for lang, decision in decisions.items():
            self.write_debug(f"[smart-subs] {lang}: {decision}")

        return info
