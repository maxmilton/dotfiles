#!/bin/bash
set -eu
set -o pipefail

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

test "$(id -u)" -eq "0" && die "Do not run as root"

export MACHINE_NAME="${MACHINE_NAME:-dev}"
export MACHINE_DIR="${HOME}/.machines/${MACHINE_NAME}"

umask 022

sudo mkdir -pv "${MACHINE_DIR}/var/lib/pacman"
sudo chown root:"$(id -gn)" "$MACHINE_DIR"

sudo ln -svf /var/lib/pacman/sync "${MACHINE_DIR}/var/lib/pacman/"

sudo pacstrap -icMG "$MACHINE_DIR" systemd busybox opendoas
sudo paru --root "$MACHINE_DIR" --cachedir /var/cache/pacman/pkg -S base-devel code code-features code-marketplace fish git

sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m -G wheel -s /usr/bin/fish xxxx && passwd -d xxxx"

# https://wiki.archlinux.org/title/Getty#Nspawn_console
sudo mkdir -pv "${MACHINE_DIR}/etc/systemd/system/console-getty.service.d"
sudo tee -a "${MACHINE_DIR}/etc/systemd/system/console-getty.service.d/autologin.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin xxxx - 115200,38400,9600 \$TERM
EOF

sudo mkdir -pv "${MACHINE_DIR}/etc/systemd/system/container-getty@.service.d"
sudo tee -a "${MACHINE_DIR}/etc/systemd/system/container-getty@.service.d/autologin.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin xxxx - 115200,38400,9600 \$TERM
EOF

# sudo mkdir -pv "${MACHINE_DIR}/home/xxxx/.config/systemd/user"
# sudo tee -a "${MACHINE_DIR}/home/xxxx/.config/systemd/user/${MACHINE_NAME}.service" <<EOF
# [Unit]
# Description=VS Code
# After=network.target
#
# [Service]
# Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
# Environment=DISPLAY=:0
# Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
# Environment=XDG_SESSION_TYPE=wayland
# Environment=QT_QPA_PLATFORM=wayland
# Environment=MOZ_ENABLE_WAYLAND=1
# Environment=GTK_THEME=Adwaita:dark
# ExecStart=/usr/bin/code --ozone-platform-hint=auto --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3
#
# [Install]
# WantedBy=default.target
# EOF

sudo tee -a "${MACHINE_DIR}/home/xxxx/.config/fish/conf.d/init.fish" <<EOF
status is-interactive || exit

set -gx COLORTERM truecolor
set -gx TERM xterm-256color
set -g hydro_color_prompt magenta
# set -e SSH_AGENT_PID
set -g -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
set -g -x GPG_TTY (tty)
# while ! test -S "$XDG_RUNTIME_DIR"bus; sleep 1; end
systemctl --user start gpg-agent.service
dbus-update-activation-environment --systemd --all
EOF

sudo tee -a "${MACHINE_DIR}/home/xxxx/code.sh" <<EOF
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XAUTHORITY=/home/xxxx/.Xauthority
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export GTK_THEME=Adwaita:dark

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)
eval $(gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
while ! test -S "$XDG_RUNTIME_DIR/bus"; do sleep 1; done

systemctl --user start gpg-agent.service
dbus-update-activation-environment --systemd --all

/usr/bin/code --ozone-platform-hint=auto --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3
EOF

sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R xxxx:xxxx /home/xxxx/.config"
sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "chmod 700 /home/xxxx/code.sh"
# sudo systemd-nspawn -D "$MACHINE_DIR" --user xxxx sh -c "systemctl --user enable $MACHINE_NAME.service"

# sudo systemd-nspawn -D "$MACHINE_DIR" sh -c "pacman -S archlinux-keyring && pacman-key --init && pacman-key --populate archlinux"

# msg -e "\033[1;31mManually run:\033[0m"
# msg "paru -Syr \"$MACHINE_DIR\" base-devel git paru-bin code nodejs gnome-keyring"
# msg -e "\033[1;31mThen run:\033[0m"
# msg "systemd-nspawn -D \"$MACHINE_DIR\" --user xxxx sh -c \"paru -S code-features code-marketplace\""

# msg -e "\033[1;31mThen run:\033[0m"

# script_dir="$(cd "$(dirname "$0")" && pwd)"
# doas "$script_dir"/link-busybox.sh
# doas ln -vs --no-dereference /usr/bin/busybox /usr/local/bin/unzip
# curl -fsSL https://bun.sh/install | bash
# ~/.bun/bin/bun add -g pnpm npm yarn
# ~/.bun/bin/yarn set version stable
