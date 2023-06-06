#!/bin/sh -eu

curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn

if test -L /usr/bin/sudo; then
  sudo rm /usr/bin/sudo
fi

paru -Syu
paru -S --noconfirm base-devel nodejs
