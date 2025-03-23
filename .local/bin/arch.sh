#!/bin/sh
set -eu

if test ! -z "$(machinectl show --property=State=running arch 2>&-)"; then
  sudo systemd-run \
    --machine=arch \
    --uid=max \
    --gid=max \
    --shell
else
  ephemeral=$([ "$*" = "-x" ] || echo --ephemeral)

  sudo systemd-nspawn \
    --directory=/var/lib/machines/arch \
    --bind-ro="$XDG_RUNTIME_DIR"/pulse/native:/run/user/host/pulse/native \
    --bind-ro="$XDG_RUNTIME_DIR"/wayland-0:/run/user/host/wayland-0 \
    --bind=/dev/dri/card0 \
    --bind=/dev/dri/renderD128 \
    --bind=/tmp/.X11-unix/X0 \
    --bind="$XAUTHORITY":/home/max/.Xauthority \
    --bind="$HOME"/Downloads:/home/max/Downloads \
    --overlay="$HOME"/Projects::/home/max/Projects \
    --overlay=/run/media/max/Store::/mnt/Store \
    --boot $ephemeral

    # TODO: Use when it's possible to specify bind/overlay owner uid or there's a workaround
    # --private-users=pick \
fi
