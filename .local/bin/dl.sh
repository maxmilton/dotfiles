#!/bin/sh
set -eu
# REF: https://github.com/yt-dlp/yt-dlp/blob/master/README.md
# REF: https://chatgpt.com/share/6a84f8fa-3ed8-83ec-99d8-581529bff1b9
# SEE: .config/yt-dlp/plugins/smart-subs/yt_dlp_plugins/extractor/smart_subs.py
# TIP: Only >15 min: --match-filters 'duration>900'
#
# TODO: Remove `--sleep-subtitles 60`, see: .config/yt-dlp/plugins/smart-subs/README.md

if yt-dlp --ignore-config -v 2>&1 | grep -q 'yt-dlp version nightly@'; then
  yt-dlp -U
fi

exec yt-dlp \
  -t sleep \
  --sleep-subtitles 60 \
  --retry-sleep 'exp=2:30' \
  --retry-sleep 'fragment:exp=1:20' \
  --concurrent-fragments 4 \
  --abort-on-unavailable-fragments \
  --download-archive "${XDG_RUNTIME_DIR:?}/yt-dlp.archive" \
  --format-sort-reset \
  --format-sort 'res:2160,hdr:sdr' \
  --sub-langs 'en,ko' \
  --sub-format 'vtt/best' \
  --compat-options no-keep-subs \
  --write-subs \
  --write-auto-subs \
  --embed-subs \
  --embed-thumbnail \
  --embed-chapters \
  --embed-metadata \
  --sponsorblock-mark all \
  --sponsorblock-remove default \
  --output '%(release_date>%Y-%m-%d,upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s' \
  --no-playlist \
  "$@"
  # XXX: Use with HDR supported monitor:
  # --format-sort 'res:2160' \
  # TODO: If custom "smart subs" yt-dlp plugin doesn't work, revert to:
  # --sub-langs 'en.*,ko.*' \
