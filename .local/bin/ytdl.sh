#!/bin/sh
set -eu

# https://github.com/yt-dlp/yt-dlp#format-selection-examples

yt-dlp \
  --concurrent-fragments 3 \
  --sub-langs "en.*,kr" \
  --embed-subs \
  --sponsorblock-mark all \
  --sponsorblock-remove default \
  --format-sort "res:4096" \
  $@
  # --write-comments \
  # --write-thumbnail \
  # --write-subs \
  # --format 'bv*[height<=4096]+ba/b[height<=4096]' \
