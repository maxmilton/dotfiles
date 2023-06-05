#!/bin/sh -eu
# Btrfs only; create snapshot of root filesystem and boot an ephemeral instance
sudo btrfs subvolume show / >/dev/null || exit 1
sudo systemd-nspawn -D / -xb --overlay="$HOME"
