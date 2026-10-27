#!/usr/bin/env bash
set -euo pipefail

# Serve Playwright browsers from a container matching the current bun project's Playwright version.
# Usage: playwright_server.sh (from a bun project); listens on 127.0.0.1 only, without auth.

msg() { echo >&2 -e "${1-}"; }
die() { printf '\033[31merror: \033[0m%s\n' "$1" >&2; exit 1; }

(($# == 0)) || die "Usage: ${0##*/} (no arguments; run from a bun project)"

port=3000

output=$(bun --bun playwright --version) || die "Playwright not found in this project"
[[ $output =~ ^Version\ ([0-9]+\.[0-9]+\.[0-9]+)$ ]] || die "Unexpected Playwright version: $output"
version=${BASH_REMATCH[1]}

msg "\033[2mRun tests using:"
msg "==========================="
msg "PW_TEST_CONNECT_WS_ENDPOINT='ws://127.0.0.1:${port}/' \\"
msg "PW_TEST_CONNECT_EXPOSE_NETWORK='<loopback>' \\"
msg "bun run test:e2e --project='*'"
msg "===========================\033[0m"

exec podman run -it --rm --init \
  -p "127.0.0.1:${port}:${port}" \
  --ipc=host \
  --user pwuser \
  --workdir /home/pwuser \
  --volume playwright-npm-cache:/home/pwuser/.npm \
  "mcr.microsoft.com/playwright:v${version}-resolute" \
  npx -y --prefer-offline "playwright@${version}" run-server --port "$port" --host 0.0.0.0
