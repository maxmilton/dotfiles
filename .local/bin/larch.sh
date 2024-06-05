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
    --bind=/dev/dri/card1 \
    --bind=/dev/dri/renderD128 \
    --bind=/tmp/.X11-unix/X0 \
    --bind="$XAUTHORITY":/home/max/.Xauthority \
    --bind=/home/max/Downloads \
    --overlay=/home/max/Projects::/home/max/Projects \
    --directory=/var/lib/machines/arch \
    --boot $ephemeral

    # TODO: Use when it's possible to specify bind/overlay owner uid or there's a workaround
    # --private-users=pick \
fi
