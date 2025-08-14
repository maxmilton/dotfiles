#!/bin/bash
set -eu
set -o pipefail

doas pacman -S --noconfirm --needed wireshark-qt qt5-wayland ttf-dejavu

export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
/usr/bin/wireshark "$@"
