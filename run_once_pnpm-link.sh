#!/bin/sh
set -euo pipefail

# Link global pnpm with home so it can be managed be chezmoi
sudo ln "$HOME"/.config/pnpm/package.json /usr/pnpm-global/5/package.json
