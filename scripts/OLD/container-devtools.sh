#!/bin/sh -eu

# TODO: Populate persistent data rather than populate on every run
doas pacman -S --noconfirm --needed archlinux-keyring
doas pacman-key --init
doas pacman-key --populate archlinux

if test -L /usr/bin/sudo; then
  doas rm /usr/bin/sudo
fi

doas pacman -S --noconfirm --needed base-devel nodejs

script_dir="$(cd "$(dirname "$0")" && pwd)"
doas "$script_dir"/link-busybox.sh
doas ln -vs --no-dereference /usr/bin/busybox /usr/local/bin/unzip

# nosemgrep: curl-pipe-bash
curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn
~/.bun/bin/yarn set version stable

echo "export PATH=$PATH:~/.bun/bin/"
