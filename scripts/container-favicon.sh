#!/bin/sh -eu

# TODO: Populate persistent data rather than populate on every run
# doas pacman -S --noconfirm --needed archlinux-keyring
# doas pacman-key --init
# doas pacman-key --populate archlinux

sudo pacman -S --noconfirm --needed inkscape imagemagick ttf-dejavu libwpg

convert logo.svg -resize 16x16 -background none -alpha remove -alpha off -colors 16 favicon.ico
# convert logo.svg -resize 16x16 -background none -alpha remove -alpha off favicon2.ico
# convert logo.svg -resize 16x16 -background none favicon3.ico

inkscape --export-filename=logo.png -w 2048 -h 2048 logo.svg
convert logo.png -resize 512x512 google-touch-icon.png
convert logo.png -resize 128x128 apple-touch-icon.png
rm logo.png

# # Chrome extension icons:
# inkscape --export-filename=icon16.png -w 16 -h 16 icon.svg
# inkscape --export-filename=icon48.png -w 48 -h 48 icon.svg
# inkscape --export-filename=icon128.png -w 128 -h 128 icon.svg
