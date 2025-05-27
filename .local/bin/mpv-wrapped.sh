#!/usr/bin/busybox sh
# Secure mpv wrapper using Bubblewrap
set -Eeu

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

exec 11<<EOF
$(getent passwd "$(id -u)" 65534)
EOF

exec 12<<EOF
$(getent group "$(id -g)" 65534)
EOF

exec bwrap \
  --ro-bind /usr /usr \
  --symlink usr/lib64 /lib64 \
  --ro-bind /sys /sys \
  --dev /dev \
  --dev-bind /dev/dri /dev/dri \
  --proc /proc \
  --ro-bind /etc/ca-certificates /etc/ca-certificates \
  --ro-bind /etc/fonts /etc/fonts \
  --ro-bind /etc/ssl /etc/ssl \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --file 11 /etc/passwd \
  --file 12 /etc/group \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs "$HOME" \
  --ro-bind "$HOME/Projects/dotfiles/.config/mpv" "$HOME/.config/mpv" \
  --bind "$HOME/.cache/mpv" "$HOME/.cache/mpv" \
  --bind "$HOME/.local/state/mpv" "$HOME/.local/state/mpv" \
  --ro-bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" \
  --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
  --clearenv \
  --setenv HOME "$HOME" \
  --setenv LC_ALL C.UTF-8 \
  --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
  --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
  --setenv XDG_SESSION_TYPE wayland \
  --unshare-all \
  --share-net \
  --die-with-parent \
  --ro-bind "$PWD" "$PWD" \
  --chdir "$PWD" \
  /usr/bin/mpv "$@"
  # TODO: Fix new terminal session breaking keyboard input.
  # --new-session \
