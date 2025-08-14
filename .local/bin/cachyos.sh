#!/bin/sh
set -eu

if test ! -z "$(machinectl show --property=State=running arch 2>&-)"; then
  sudo systemd-run \
    --machine=cachyos \
    --uid=max \
    --gid=max \
    --shell
else
  ephemeral=$([ "$*" = "-x" ] || echo --ephemeral)

  sudo systemd-nspawn \
    --bind-ro="${XDG_RUNTIME_DIR}"/pulse/native:/run/user/host/pulse/native \
    --bind-ro="${XDG_RUNTIME_DIR}"/wayland-0:/run/user/host/wayland-0 \
    --bind=/dev/dri/card0 \
    --bind=/dev/dri/renderD128 \
    --bind=/tmp/.X11-unix/X0 \
    --bind="$XAUTHORITY":/home/max/.Xauthority \
    --bind=/home/max/Downloads \
    --overlay=/home/max/Projects::/home/max/Projects \
    --overlay=/run/media/max/Store::/mnt/Store \
    --directory=/var/lib/machines/cachyos \
    --boot $ephemeral

  # TODO: Use when it's possible to specify bind/overlay owner uid or there's a
  # workaround... but keep in mind performance overhead and security issues.
  # --private-users=pick \
fi
