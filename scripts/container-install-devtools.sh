#!/bin/sh -eu

paru -Syu

curl -fsSL https://bun.sh/install | bash

~/.bun/bin/bun add -g pnpm npm yarn

paru -S --noconfirm nodejs
