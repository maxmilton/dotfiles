#!/bin/sh -eu

test "$(id -u)" -ne "0" && echo "You need to be root" >&2 && exit 1

export MACHINE_NAME=code
export MACHINE_DIR="/home/max/.machines/$MACHINE_NAME"

umask 022

mkdir -p "$MACHINE_DIR"
chown -R root:max "$MACHINE_DIR"
pacstrap -icMG "$MACHINE_DIR" systemd busybox

systemd-nspawn -D "$MACHINE_DIR" sh -c "useradd -m -G wheel max && passwd -d max"

# https://wiki.archlinux.org/title/Getty#Nspawn_console
mkdir -p "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/console-getty.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

mkdir -p "$MACHINE_DIR"/etc/systemd/system/container-getty@.service.d
tee -a "$MACHINE_DIR"/etc/systemd/system/container-getty@.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --keep-baud --autologin max - 115200,38400,9600 \$TERM
EOF

mkdir -p "$MACHINE_DIR"/home/max/.config/systemd/user
tee -a "$MACHINE_DIR"/home/max/.config/systemd/user/$MACHINE_NAME.service <<EOF
[Unit]
Description=VS Code
After=network.target

[Service]
Environment=PULSE_SERVER=unix:/run/user/host/pulse/native
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=/run/user/host/wayland-0
Environment=XDG_SESSION_TYPE=wayland
Environment=QT_QPA_PLATFORM=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=GTK_THEME=Adwaita:dark
ExecStart=/usr/bin/code --password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland

[Install]
WantedBy=default.target
EOF

tee -a "$MACHINE_DIR"/home/max/.config/fish/conf.d/init.fish <<EOF
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

tee -a "$MACHINE_DIR"/home/max/vscode.sh <<EOF
#!/bin/sh -eu
export PULSE_SERVER=unix:/run/user/host/pulse/native
export DISPLAY=:0
export WAYLAND_DISPLAY=/run/user/host/wayland-0
export XAUTHORITY=/home/max/.Xauthority
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

/usr/bin/code --password-store="gnome" --enable-features=UseOzonePlatform --ozone-platform=wayland
EOF

systemd-nspawn -D "$MACHINE_DIR" sh -c "chown -R max:max /home/max/.config"
systemd-nspawn -D "$MACHINE_DIR" --user max sh -c "systemctl --user enable $MACHINE_NAME.service"
systemd-nspawn -D "$MACHINE_DIR" sh -c "chmod 700 /home/max/vscode.sh"

systemd-nspawn -D "$MACHINE_DIR" sh -c "pacman -S archlinux-keyring && pacman-key --init && pacman-key --populate archlinux"

echo -e "\033[1;31mManually run:\033[0m"
echo "paru -Syr \"$MACHINE_DIR\" base-devel git paru-bin code nodejs gnome-keyring"
echo -e "\033[1;31mThen run:\033[0m"
echo "systemd-nspawn -D \"$MACHINE_DIR\" --user max sh -c \"paru -S code-features code-marketplace\""

# echo -e "\033[1;31mThen run:\033[0m"

# script_dir="$(cd "$(dirname "$0")" && pwd)"
# doas "$script_dir"/link-busybox.sh
# doas ln -vs --no-dereference /usr/bin/busybox /usr/local/bin/unzip
# curl -fsSL https://bun.sh/install | bash
# ~/.bun/bin/bun add -g pnpm npm yarn
# ~/.bun/bin/yarn set version stable
