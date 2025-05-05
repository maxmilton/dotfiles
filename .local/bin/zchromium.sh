#!/bin/sh
set -eu
pkexec systemd-nspawn \
  --directory="$HOME"/.machines/zchromium \
  --user=xxxx --chdir=/home/xxxx \
  --bind-ro="${XDG_RUNTIME_DIR}/pulse/native":/run/user/host/pulse/native \
  --bind-ro="${XDG_RUNTIME_DIR}/wayland-0":/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind="${HOME}/Downloads":/home/xxxx/Downloads \
  --setenv=PULSE_SERVER=unix:/run/user/host/pulse/native \
  --setenv=DISPLAY="$DISPLAY" \
  --setenv=WAYLAND_DISPLAY=/run/user/host/wayland-0 \
  --setenv=XDG_SESSION_TYPE=wayland \
  --as-pid2 \
  --ephemeral \
    /usr/bin/chromium --ozone-platform-hint=wayland --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3 $@
