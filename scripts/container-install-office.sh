#!/bin/sh -eu
pacman -Syu --noconfirm
pacman -S --noconfirm libreoffice-fresh hunspell hunspell-en_au hyphen hyphen-en libmythes mythes-en gtk3 gtk4 ttf-liberation
ln -vsf /usr/bin/busybox /usr/local/bin/sed
