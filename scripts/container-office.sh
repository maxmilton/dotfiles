#!/bin/sh -eu

doas pacman -S --noconfirm --needed libreoffice-fresh hunspell hunspell-en_au hyphen hyphen-en libmythes mythes-en gtk3 gtk4 ttf-liberation
doas ln -vsf /usr/bin/busybox /usr/local/bin/sed

export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
/usr/bin/libreoffice --nologo $@
