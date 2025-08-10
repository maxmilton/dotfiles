#!/bin/sh
set -eu
pkexec systemd-nspawn \
  --directory="${HOME}/.machines/brave" \
  --user=xxxx --chdir=/home/xxxx \
  --bind-ro="${XDG_RUNTIME_DIR}/pulse/native":/run/user/host/pulse/native \
  --bind-ro="${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}":/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind="${HOME}/Downloads":/home/xxxx/Downloads \
  --boot --ephemeral $@
  # --bind-ro="${HOME}/Projects":/home/xxxx/Projects \
