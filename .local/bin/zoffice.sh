#!/bin/sh -eu
pkexec systemd-nspawn \
  --directory=/home/max/.machines/office \
  --user=$USER --chdir=$HOME \
  --bind-ro=/run/user/1000/pulse/native:/run/user/host/pulse/native \
  --bind-ro=/run/user/1000/wayland-0:/run/user/host/wayland-0 \
  --bind=/dev/dri/card0 \
  --bind=/dev/dri/renderD128 \
  --bind=/tmp/.X11-unix/X0 \
  --bind-ro=/usr/share/fonts \
  --bind=/home/max/Documents \
  --bind=/home/max/Downloads \
  --setenv=PULSE_SERVER=unix:/run/user/host/pulse/native \
  --setenv=DISPLAY=$DISPLAY \
  --setenv=WAYLAND_DISPLAY=/run/user/host/wayland-0 \
  --setenv=MOZ_ENABLE_WAYLAND=1 \
  --setenv=XDG_SESSION_TYPE=wayland \
  --setenv=XDG_RUNTIME_DIR=/run/user/1000 \
  --as-pid2 \
    /usr/bin/libreoffice --nologo $@
  # --bind=/dev/hidraw0 \
  # --bind=/dev/hidraw1 \
  # --bind=/dev/hidraw2 \
  # --bind=/dev/hidraw3 \
