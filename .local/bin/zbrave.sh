#!/bin/sh -eu
pkexec systemd-nspawn \
  --directory=/home/max/.machines/zbrave \
  --user=$USER --chdir=$HOME \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind=/home/max/Downloads \
  --setenv=PULSE_SERVER=unix:/run/user/host/pulse/native \
  --setenv=DISPLAY=$DISPLAY \
  --setenv=WAYLAND_DISPLAY=/run/user/host/wayland-0 \
  --setenv=XDG_SESSION_TYPE=wayland \
  --as-pid2 \
    /usr/bin/brave --ozone-platform-hint=wayland --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3 $@
  # --bind=/dev/hidraw0 \
  # --bind=/dev/hidraw1 \
  # --bind=/dev/hidraw2 \
  # --bind=/dev/hidraw3 \
