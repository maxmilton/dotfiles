#!/bin/sh -eu

curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn

paru -Syu
paru -S --noconfirm base-devel nodejs
