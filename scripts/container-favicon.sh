#!/bin/bash
set -Eeuo pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

# TODO: Populate persistent data rather than populate on every run
# doas pacman -S --noconfirm --needed archlinux-keyring
# doas pacman-key --init
# doas pacman-key --populate archlinux

# Check for required tools
command -v inkscape >/dev/null || \
  sudo pacman -S --noconfirm --needed inkscape imagemagick ttf-dejavu libwpg pngquant oxipng zopfli

optimize_png() {
  [ $# -ne 2 ] && die "Usage: optimize_png <input_file> <output_file>"
  input="$1"
  output="$2"
  temp=$(mktemp "${TMPDIR:-/tmp}/tmp.XXXXXX.png")
  trap 'rm -f "$temp"' EXIT
  msg "Optimizing: $output"

  # Step 1: pngquant (lossy compression, optional)
  pngquant -f --quality=75-95 --speed 1 "$input" --output "$temp" || die "pngquant failed"

  # Step 2: oxipng (lossless, max compression, strip metadata)
  oxipng -o max --strip all "$temp" || die "oxipng failed"

  # Step 3: zopflipng (final max compression)
  zopflipng -y -m --filters=0meb --lossy_8bit --lossy_transparent "$temp" "$output" || die "zopflipng failed"
}

magick -background transparent logo.svg -resize 16x16 favicon.ico
magick logo.svg -resize 16x16 -background none -alpha remove -alpha off -colors 16 favicon2.ico
# magick -background transparent logo.svg -resize 16x16 -colors 16 favicon3.ico

inkscape --export-filename=google-touch-icon.png -w 512 -h 512 logo.svg
inkscape --export-filename=apple-touch-icon.png -w 128 -h 128 logo.svg
optimize_png google-touch-icon.png google-touch-icon.png
optimize_png apple-touch-icon.png apple-touch-icon.png

# magick -density 4096 -background transparent logo.svg -resize 512x512 google-touch-icon.png
# magick -background transparent logo.svg -resize 128x128 apple-touch-icon.png
# optimize_png google-touch-icon.png google-touch-icon.png
# optimize_png apple-touch-icon.png apple-touch-icon.png

# Chrome extension icons:
inkscape --export-filename=icon16.png -w 16 -h 16 logo.svg
inkscape --export-filename=icon48.png -w 48 -h 48 logo.svg
inkscape --export-filename=icon128.png -w 128 -h 128 logo.svg
optimize_png icon16.png icon16.png
optimize_png icon48.png icon48.png
optimize_png icon128.png icon128.png

# magick -background transparent logo.svg -resize 16x16 icon16.png
# magick -background transparent logo.svg -resize 48x48 icon48.png
# magick -background transparent logo.svg -resize 128x128 icon128.png
# optimize_png icon16.png icon16.png
# optimize_png icon48.png icon48.png
# optimize_png icon128.png icon128.png
