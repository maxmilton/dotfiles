#!/bin/sh -eu

if test ! -z "$(machinectl show --property=State=running code 2>&-)"; then
  # sudo systemd-run \
  #   --machine=code \
  #   --uid=max \
  #   --gid=max \
  #   --shell
  sudo machinectl login code
else
  sudo systemd-nspawn \
    --directory="$HOME"/.machines/code \
    --bind-ro="$XDG_RUNTIME_DIR"/pulse/native:/run/user/host/pulse/native \
    --bind-ro="$XDG_RUNTIME_DIR"/wayland-0:/run/user/host/wayland-0 \
    --bind=/dev/dri/card1 \
    --bind=/dev/dri/renderD128 \
    --bind=/tmp/.X11-unix/X0 \
    --bind="$XAUTHORITY":/home/max/.Xauthority \
    --bind="$HOME"/Downloads:/home/max/Downloads \
    --bind="$HOME"/Projects:/home/max/Projects \
    --capability=CAP_IPC_LOCK \
    --boot
fi
