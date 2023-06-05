#!/bin/sh -eu
# Btrfs only; create a snapshot of the root filesystem and boot into an ephemeral instance of it
test sudo btrfs subvolume show / &>/dev/null || { echo 'dir / is not a btrfs subvolume'; exit 1 }
sudo systemd-nspawn -D / -xb
