#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$cmd mkdir -v -p "$TARGET_DIR/.config/fish/functions"
