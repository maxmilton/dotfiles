#!/bin/sh
set -eu
yt-dlp \
  --concurrent-fragments 3 \
  --sub-langs "en" \
  --embed-subs \
  --sponsorblock-mark all \
  --sponsorblock-remove default \
  --format-sort "res:2160" \
  $@
