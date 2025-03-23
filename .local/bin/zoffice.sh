#!/bin/sh
set -eu
pkexec systemd-nspawn \
  --directory="$HOME"/.machines/office \
  --user="$USER" --chdir="$HOME" \
  --bind-ro="$XDG_RUNTIME_DIR"/pulse/native:/run/user/host/pulse/native \
  --bind-ro="$XDG_RUNTIME_DIR"/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind="$HOME"/Documents \
  --bind="$HOME"/Downloads \
  --setenv=PULSE_SERVER=unix:/run/user/host/pulse/native \
  --setenv=DISPLAY="$DISPLAY" \
  --setenv=WAYLAND_DISPLAY=/run/user/host/wayland-0 \
  --setenv=MOZ_ENABLE_WAYLAND=1 \
  --setenv=XDG_SESSION_TYPE=wayland \
  --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  --as-pid2 \
    /usr/bin/libreoffice --nologo $@
