#!/bin/sh
set -eu
# https://github.com/yt-dlp/yt-dlp/blob/master/README.md
# TIP: To filter for items over 15 mins: --match-filters 'duration>900'
yt-dlp \
  --concurrent-fragments 4 \
  --format-sort 'res:4096,vcodec:vp9.2,lang,quality,fps,hdr:10,channels,acodec,br,asr,source' \
  --merge-output-format mkv \
  --remux-video mkv \
  --sub-langs 'en.*,kr' \
  --sub-format best \
  --embed-subs \
  --embed-thumbnail \
  --embed-metadata \
  --mtime \
  --sponsorblock-mark default \
  --sponsorblock-remove default \
  $@
  # --recode-video 'webm>webm/mkv' \
