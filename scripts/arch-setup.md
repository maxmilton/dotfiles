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

- <https://wiki.archlinux.org/title/security>
- <https://theprivacyguide1.github.io/linux_hardening_guide>
- <https://kyau.net/wiki/ArchLinux:Security>

`/etc/systemd/resolved.conf`:
```
[Resolve]
DNS=2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com 1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com
#FallbackDNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net 8.8.8.8#dns.google 2606:4700:4700::1111#cloudflare-dns.com 2620:fe::9#dns.quad9.net 2001:4860:4860::8888#dns.google
FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
MulticastDNS=no
LLMNR=no
ReadEtcHosts=no
```

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

`/etc/nftables.conf`:
```
#!/usr/bin/nft -f

flush ruleset

table inet filter {
  set wireguard_ips {
    type ipv4_addr
    flags interval
    elements = {
      # ProtonVPN AU
      180.149.229.130,
      # ProtonVPN JP
      37.19.205.155,
      # ProtonVPN KR
      79.110.55.2,
      # ProtonVPN TW
      188.214.106.178,
      # ProtonVPN US
      156.146.54.97, 31.13.189.226
    }
  }

  set openvpn_ips {
    type ipv4_addr
    flags interval
    elements = {
      # ProtonVPN AU
      103.108.231.18, 103.214.20.98, 103.214.20.210, 103.216.220.98, 138.199.33.225, 138.199.33.236, 180.149.229.130,
      # ProtonVPN JP
      103.125.235.19, 37.19.205.155, 37.19.205.223, 45.14.71.6,
      # ProtonVPN KR
      79.110.55.2,
      # ProtonVPN US
      146.70.174.210, 146.70.183.130, 146.70.183.18, 146.70.195.82, 146.70.202.18, 149.102.226.193, 185.230.126.18, 19
    }
  }

  set openvpn_ports {
    type inet_service
    elements = { 80, 1194, 4569, 5060, 51820 }
  }

  chain input {
    type filter hook input priority 0
    policy drop

    ct state { established, related } accept
    ct state invalid drop
    iifname { "lo", "tun0", "wg0", "wg1", "wg2", "wg3", "wg4", "wg5" } accept
    pkttype host limit rate 5/second counter reject with icmpx type admin-prohibited
    counter
  }

  chain forward {
    type filter hook forward priority 0
    policy drop
  }

  chain output {
    type filter hook output priority 0
    policy drop

    ct state { established, related } accept
    oifname { "lo", "tun0", "wg0", "wg1", "wg2", "wg3", "wg4", "wg5" } accept

    meta nfproto ipv4 ip daddr @wireguard_ips udp dport 51820 accept
    meta nfproto ipv4 ip daddr @openvpn_ips th dport @openvpn_ports accept

    # Allow local traffic
    #ip daddr 192.168.0.0/16 oifname != { "tun0", "wg0" } accept
    #ip6 daddr fe80::/10 oifname != { "tun0", "wg0" } accept
  }
}

table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100
    oifname { "tun0", "wg0", "wg1", "wg2", "wg3", "wg4", "wg5" } masquerade
  }
}
```

`/boot/loader/entries/linux-hardened.conf`:
```
title   Arch Linux (linux-hardened)
linux   /vmlinuz-linux-hardened
initrd  /intel-ucode.img
initrd  /initramfs-linux-hardened.img
options cryptdevice=PARTUUID=43c9fc6d-afe7-46b9-93c5-e08c6a5383cb:root root=/dev/mapper/root zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs lsm=landlock,lockdown,yama,integrity,apparmor,bpf apparmor=1 lockdown=confidentiality slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 vsyscall=none debugfs=off oops=panic module.sig_enforce=1 quiet loglevel=0
```
