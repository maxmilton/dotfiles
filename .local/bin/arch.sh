#!/bin/sh -eu

if test ! -z "$(machinectl show --property=State=running arch 2>&-)"; then
  sudo systemd-run \
    --machine=arch \
    --uid=max \
    --gid=max \
    --shell
else
  ephemeral=$([ "$*" = "-x" ] || echo --ephemeral)

  sudo systemd-nspawn \
    --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
    --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
    --bind=/dev/dri/card0 \
    --bind=/dev/dri/renderD128 \
    --bind=/tmp/.X11-unix/X0 \
    --bind=/home/max/Downloads \
    --bind=/home/max/Projects \
    --directory=/var/lib/machines/arch \
    --boot $ephemeral
fi
