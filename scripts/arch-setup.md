# Arch Linux Setup

TODO: Write up step-by-step instructions rather than these loose notes.

```sh
# guided install
archinstall

# choose seperate /home dir so it can be mounted with noexec,nodev etc.
```

```sh
# extra packages
busybox
eza
fd
fish
git
```

```sh
# link busybox utils
scripts/link-busybox.sh
```

```sh
# desktop packages
gnome-keyring
gnome-shell
gnome-terminal
iwd
nautilus
pipewire
wireplumber
```

```sh
# turn off uncessecary gnome stuff
scripts/disable-gnome-services.sh
```

```sh
# edit pacman config; enable parallel downloads + colour
vi /etc/pacman.conf
```

<!--
```sh
#setup yay-bin
https://github.com/Jguer/yay#binary
```
-->

```sh
#setup paru-bin
https://github.com/Morganamilo/paru#installation
```

---

```sh
# interesting packages that may be worth installing
arch-install-scripts
aria2
brave-bin (AUR)
code
code-features (AUR)
code-marketplace (AUR)
cpupower (for desktop) OR power-profiles-daemon (for laptop)
eza
fd
fish
fwupd
fzy
git
gnome-characters
gnome-control-center
gnome-shell-extension-clipboard-history (AUR)
gnome-tweaks
helix
htop OR btop
jq
man-db
man-pages
mpv
noto-fonts-cjk
noto-fonts-emoji
ripgrep
wl-clipboard
xdg-utils
paru-bin (AUR, needs manual initial setup)
yt-dlp
```

```sh
# security packages
firejail
hardened_malloc
nftables
opendoas
~~sbupdate (AUR, for updating Secure Boot keys)~~
sbctl (modern replacement for sbupdate)
```

```sh
# misc. packages (consider run some of these from a container)
elfkickers (contains sstrip)
gifsicle
imagemagick
inkscape
mkcert
nodejs
radare2
shellcheck
ttf-jetbrains-mono
ttf-unifont
upx
visidata
xdg-user-dirs
xorg-server-xvfb
```

- Set up iwd
- Set up systemd-resolved
  - Use DNS over TLS
- Set up systemd-networkd
  - Improve TCP slow start window
- Create machines; `mkarch.sh arch`

`/etc/systemd/network/25-wlan.network`:
```
# https://man.archlinux.org/man/systemd.network.5
# https://www.freedesktop.org/software/systemd/man/systemd.network.html

[Match]
Name=wlan*

[Network]
DHCP=true
IgnoreCarrierLoss=3s
DNS=::1 127.0.0.1

[DHCPv4]
UseDNS=no

[DHCPv6]
UseDNS=no

[IPv6AcceptRA]
UseDNS=no

[Route]
Gateway=_dhcp4
InitialCongestionWindow=30
InitialAdvertisedReceiveWindow=30

[Route]
Gateway=_ipv6ra
InitialCongestionWindow=30
InitialAdvertisedReceiveWindow=30
```
