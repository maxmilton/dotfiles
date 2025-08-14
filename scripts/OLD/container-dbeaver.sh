#!/bin/bash
set -eu
set -o pipefail

if ! type /usr/bin/dbeaver >/dev/null 2>&1; then
  # TODO: Populate persistent data rather than populate on every run
  doas pacman -S --noconfirm --needed archlinux-keyring
  doas pacman-key --init
  doas pacman-key --populate archlinux

  doas pacman -S --noconfirm --needed dbeaver
fi

export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark
/usr/bin/dbeaver "$@"
