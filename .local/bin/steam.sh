#!/bin/sh -eu

# https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/systemd-nspawn-containers.md
# https://web.archive.org/web/20190117095652/http://ludiclinux.com/Nspawn-Steam-Container/
# https://wiki.archlinux.org/title/Gamepad

# fix ubisoft connectivity
sudo sysctl -w net.ipv4.tcp_mtu_probing=1

# https://wiki.archlinux.org/title/gaming#Game_compatibility
sudo sysctl -w vm.max_map_count=2147483642

sudo systemd-nspawn \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind="$XAUTHORITY":/home/max/.Xauthority \
  --bind-ro=/home/max/Projects \
  --bind=/home/max/Downloads \
  --bind=/run/media/max/Store/Steam:/mnt/Store \
  --bind=/dev/input \
  --bind-ro=/usr/lib/modules \
  --property=DeviceAllow="char-usb_device rwm" \
  --property=DeviceAllow="char-input rwm" \
  --directory=/var/lib/machines/steam \
  --boot
