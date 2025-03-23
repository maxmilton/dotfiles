#!/bin/sh
set -eu
pkexec systemd-nspawn \
  --directory="$HOME"/.machines/vms \
  --bind-ro="$XDG_RUNTIME_DIR"/pulse/native:/run/user/host/pulse/native \
  --bind-ro="$XDG_RUNTIME_DIR"/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind="$XAUTHORITY":/home/max/.Xauthority \
  --bind=/dev/kvm \
  --bind=/dev/vfio \
  --bind="$HOME"/Downloads:/home/max/Downloads \
  --bind-ro="$HOME"/Projects:/home/max/Projects \
  --bind-ro=/run/media/max/Store \
  --boot
  # --capability=all \
