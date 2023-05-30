#!/bin/sh -eu
sudo systemd-nspawn \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind=/home/max/Downloads \
  --bind=/home/max/Projects \
  --directory=/home/max/machines/librewolf \
  --boot --ephemeral
