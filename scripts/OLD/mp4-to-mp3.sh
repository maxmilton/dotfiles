#!/bin/bash
set -eu

ffmpeg -i "$1".mp4 -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$1".mp3
