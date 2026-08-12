#!/bin/bash
set -eu
set -o pipefail

# https://github.com/livebook-dev/livebook

doas pacman -S --noconfirm --needed elixir

mkdir -p ~/livebook

# shellcheck disable=SC1010
mix do local.rebar --force, local.hex --force
mix escript.install hex livebook

~/.mix/escripts/livebook server
