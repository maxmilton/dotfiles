#!/bin/sh -eu

doas pacman -S --noconfirm --needed midori
# doas pacman -S --noconfirm --needed epiphany

export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
/usr/bin/midori $@
# /usr/bin/epiphany $@
