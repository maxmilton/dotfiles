# Smart Subs

This yt-dlp extractor plugin reduces YouTube's subtitle dictionaries to one
English track and one Korean track at most. It is designed for this yt-dlp
configuration:

```text
--sub-langs en,ko
--write-subs
--write-auto-subs
```

For each target language, the plugin prefers uploader captions, then original
automatic captions. For a still-missing target, it selects a YouTube
translation from a confirmed native caption source, preferring uploader
captions over automatic captions as that source. When native language is
unknown, a final coverage fallback accepts an explicitly source-keyed
translation of uploader captions; if several qualify, it uses lexical source
key order.

The selected subtitle is embedded with its target language and a provenance
label, such as `English [auto-translated native uploader captions (fr)]`. MPV
and `ffprobe` display this as the subtitle stream title.

Use `--verbose` to see the detected native language and the source selected for
each output language.

## Troubleshooting

YouTube may return HTTP 429 when yt-dlp downloads an automatically translated
caption, even though subtitle extraction and an earlier caption download
succeeded. Normal download retries do not retry this response. The accompanying
`dl.sh` uses `--sleep-subtitles 60`, the anonymous workaround recommended in
[yt-dlp issue #13831](https://github.com/yt-dlp/yt-dlp/issues/13831).

The delay applies before every subtitle download, so requesting both English
and Korean can add about two minutes. Fresh browser-session cookies are an
alternative when that latency is unacceptable.

## Tests

Run the deterministic suite with a Python environment that provides yt-dlp:

```sh
python -m unittest discover -s tests -v
```

When yt-dlp is installed as a zipapp executable, test against that exact build
instead of another installed Python package:

```sh
PYTHONPATH="$(command -v yt-dlp)" python -m unittest discover -s tests -v
```

The live compatibility tests are skipped by default. These verified examples
exercise English, Korean, and third-language original ASR captions:

```sh
SMART_SUBS_EN_URL='https://www.youtube.com/watch?v=XuoqKYxDHVc' \
SMART_SUBS_KO_URL='https://www.youtube.com/watch?v=UfytekahtBU' \
SMART_SUBS_OTHER_URL='https://www.youtube.com/watch?v=_vxwlD63RmI' \
python -m unittest discover -s tests -v
```

Live tests explicitly load this checkout with `--plugin-dirs`, perform simulated
JSON extraction without downloading media or subtitles, and verify that the
plugin exposes only `en` and `ko`. These videos and their caption availability
are externally maintained and may change.
