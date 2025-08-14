#!/bin/sh
set -eu

lsusb

for d in /dev/hidraw*; do
  echo "Inspecting $d"
  udevadm info --name="$d" | grep -iE 'manufacturer|product|vendor|model|hid'
done
