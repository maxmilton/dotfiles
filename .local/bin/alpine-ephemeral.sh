#!/bin/sh -eu
doas systemd-nspawn \
  --boot \
  --ephemeral \
  --no-new-privileges=yes \
  --directory=/var/lib/machines/alpine
  #-- /sbin/getty -nl /bin/ash 0 /dev/console
