#!/bin/sh
set -eu
pkexec systemd-nspawn \
  --directory="$HOME"/.machines/librewolf \
  --bind-ro="$XDG_RUNTIME_DIR"/pulse/native:/run/user/host/pulse/native \
  --bind-ro="$XDG_RUNTIME_DIR"/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind="$HOME"/Downloads:/home/max/Downloads \
  --boot --ephemeral $@
