#!/bin/sh -eu

# https://github.com/livebook-dev/livebook

doas pacman -S --noconfirm --needed elixir

mkdir -p ~/livebook

mix do local.rebar --force, local.hex --force
mix escript.install hex livebook

~/.mix/escripts/livebook server
