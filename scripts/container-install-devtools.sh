#!/bin/sh -eu

curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn
# ~/.bun/bin/yarn set version stable

if test -L /usr/bin/sudo; then
  sudo rm /usr/bin/sudo
fi

paru -Syu --noconfirm
paru -S --noconfirm base-devel nodejs
