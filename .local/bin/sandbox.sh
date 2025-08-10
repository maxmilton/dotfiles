#!/usr/bin/busybox sh
set -euo pipefail

# Sandboxed shell for AI agents to run commands in VS Code

# if [ "$IS_INTERACTIVE" -eq 0 ]; then
#   # When non-interactive, ensure we can capture output
#   exec 1>/dev/tty
#   exec 2>/dev/tty
# fi

exec 11<<EOF
$(getent passwd "$(id -u)" 65534)
EOF

exec 12<<EOF
$(getent group "$(id -g)" 65534)
EOF

if test -t 1; then
  # Interactive (login shell + new session)
  exec bwrap \
    --ro-bind /usr /usr \
    --symlink usr/lib64 /lib64 \
    --dir /tmp \
    --dir /var \
    --symlink ../tmp var/tmp \
    --symlink /usr/bin/busybox /bin/sh \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/ca-certificates /etc/ca-certificates \
    --ro-bind /etc/ssl /etc/ssl \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --file 11 /etc/passwd \
    --file 12 /etc/group \
    --ro-bind "$HOME/Projects/dotfiles/.profile" "$HOME/.profile" \
    --bind "$HOME/Downloads" "$HOME/Downloads" \
    --bind "$HOME/Projects" "$HOME/Projects" \
    --clearenv \
    --setenv HOME "$HOME" \
    --setenv LC_ALL C.UTF-8 \
    --setenv TERM "${TERM:-linux}" \
    --setenv XDG_RUNTIME_DIR "${XDG_RUNTIME_DIR:-/tmp}" \
    --setenv XDG_SESSION_TYPE "${XDG_SESSION_TYPE:-tty}" \
    --unshare-all \
    --share-net \
    --die-with-parent \
    --new-session \
    /usr/bin/busybox sh --login
else
  # Non-interactive
  # TODO: Fix output capture when using --new-session for increased security.
  exec bwrap \
    --ro-bind /usr /usr \
    --symlink usr/lib64 /lib64 \
    --dir /tmp \
    --dir /var \
    --symlink ../tmp var/tmp \
    --symlink /usr/bin/busybox /bin/sh \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/ca-certificates /etc/ca-certificates \
    --ro-bind /etc/ssl /etc/ssl \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --file 11 /etc/passwd \
    --file 12 /etc/group \
    --ro-bind "$HOME/Projects/dotfiles/.profile" "$HOME/.profile" \
    --bind "$HOME/Downloads" "$HOME/Downloads" \
    --bind "$HOME/Projects" "$HOME/Projects" \
    --clearenv \
    --setenv HOME "$HOME" \
    --setenv LC_ALL C.UTF-8 \
    --setenv TERM "${TERM:-linux}" \
    --setenv XDG_RUNTIME_DIR "${XDG_RUNTIME_DIR:-/tmp}" \
    --setenv XDG_SESSION_TYPE "${XDG_SESSION_TYPE:-tty}" \
    --unshare-all \
    --share-net \
    --die-with-parent \
    /usr/bin/busybox sh -c "$@"
fi

# TODO: To run GUI apps: https://sloonz.github.io/posts/sandboxing-2/
# REF: https://github.com/containers/bubblewrap/blob/main/demos/bubblewrap-shell.sh
