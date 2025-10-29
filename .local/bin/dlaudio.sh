#!/bin/sh
set -eu
yt-dlp \
  --concurrent-fragments 3 \
  --sponsorblock-mark all \
  --sponsorblock-remove default \
  --extract-audio \
  $@
