#!/bin/sh -eu
sudo systemd-nspawn \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind="$XAUTHORITY":/home/max/.Xauthority \
  --bind=/dev/kvm \
  --bind=/dev/vfio \
  --bind=/home/max/Downloads \
  --bind-ro=/home/max/Projects \
  --bind-ro=/run/media/max/Store \
  --directory=/home/max/.machines/vms \
  --boot
  # --capability=all \
