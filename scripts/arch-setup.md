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
sbupdate (AUR, for updating Secure Boot keys)
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
