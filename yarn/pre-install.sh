#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

$CMD mkdir "$V" -p "$TARGET_DIR"'/.config/yarn/global'
