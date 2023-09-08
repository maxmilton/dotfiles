#!/bin/sh -eu

# fix connectivity
sudo sysctl -w net.ipv4.tcp_mtu_probing=1

sudo systemd-nspawn \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card1 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind="$XAUTHORITY":/home/max/.Xauthority \
  --bind=/home/max/Downloads \
  --bind=/run/media/max/Store/Steam:/mnt/Store \
  --bind-ro=/home/max/Projects \
  --directory=/var/lib/machines/steam \
  --boot
