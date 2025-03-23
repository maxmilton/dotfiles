#!/bin/sh
set -eu
# Btrfs only; create root filesystem snapshot and boot it ephemerally
sudo btrfs subvolume show / >/dev/null || exit 1
sudo systemd-nspawn -D / -xb --overlay=/home::/home
