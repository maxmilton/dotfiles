#!/bin/bash
set -Eeuo pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

# TODO: Populate persistent data rather than populate on every run
# doas pacman -S --noconfirm --needed archlinux-keyring
# doas pacman-key --init
# doas pacman-key --populate archlinux

# Check for required files and tools
test -f logo.svg || die "logo.svg not found"
command -v inkscape >/dev/null || \
  sudo pacman -S --noconfirm --needed inkscape imagemagick ttf-dejavu libwpg svgo pngquant oxipng zopfli

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

cp logo.svg favicon.svg
svgo --multipass favicon.svg

magick -background transparent favicon.svg -resize 16x16 favicon.ico

inkscape --export-filename=favicon.png -w 16 -h 16 favicon.svg
optimize_png favicon.png favicon.png
magick -background transparent favicon.png -colors 16 -depth 4 favicon2.ico

inkscape --export-filename=android-chrome-512x512.png -w 512 -h 512 favicon.svg
inkscape --export-filename=android-chrome-192x192.png -w 192 -h 192 favicon.svg
inkscape --export-filename=apple-touch-icon.png -w 180 -h 180 favicon.svg
optimize_png android-chrome-512x512.png android-chrome-512x512.png
optimize_png android-chrome-192x192.png android-chrome-192x192.png
optimize_png apple-touch-icon.png apple-touch-icon.png

# magick -density 4096 -background transparent favicon.svg -resize 512x512 android-chrome-512x512.png
# magick -density 4096 -background transparent favicon.svg -resize 192x192 android-chrome-192x192.png
# magick -background transparent favicon.svg -resize 128x128 apple-touch-icon.png
# optimize_png android-chrome-512x512.png android-chrome-512x512.png
# optimize_png android-chrome-192x192.png android-chrome-192x192.png
# optimize_png apple-touch-icon.png apple-touch-icon.png

# Chrome extension icons:
inkscape --export-filename=icon16.png -w 16 -h 16 favicon.svg
inkscape --export-filename=icon48.png -w 48 -h 48 favicon.svg
inkscape --export-filename=icon128.png -w 128 -h 128 favicon.svg
optimize_png icon16.png icon16.png
optimize_png icon48.png icon48.png
optimize_png icon128.png icon128.png

# magick -background transparent favicon.svg -resize 16x16 icon16.png
# magick -background transparent favicon.svg -resize 48x48 icon48.png
# magick -background transparent favicon.svg -resize 128x128 icon128.png
# optimize_png icon16.png icon16.png
# optimize_png icon48.png icon48.png
# optimize_png icon128.png icon128.png

msg "Done!"
msg "Optional: rm favicon.svg favicon.png favicon2.ico icon16.png icon48.png icon128.png"
