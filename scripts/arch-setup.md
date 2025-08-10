# Arch Linux Setup

TODO: Write up step-by-step instructions rather than these loose notes.

## Alternative

For best desktop performance install cachyos instead:

- <https://wiki.cachyos.org/cachyos_basic/download/>
- <https://wiki.cachyos.org/installation/installation_on_root/>
- Choose XFS for filesystem (or F2FS in some cases)
- <https://wiki.cachyos.org/configuration/secure_boot_setup/>
- <https://wiki.cachyos.org/configuration/general_system_tweaks/>

---

```sh
# guided install
archinstall

# choose separate /home dir so it can be mounted with noexec,nodev etc.
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
ghostty
gnome-keyring
gnome-shell
#gnome-terminal
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
# set ghostty as default terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
```

```sh
# edit pacman config; enable parallel downloads + colour
vi /etc/pacman.conf
```

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
eza (modern alt to ls)
fd (modern alt to find)
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
knot-resolver (fast DNS resolver)
lurk (modern alt to stract)
man-db
man-pages
mpv
mpv-mpris (to control via media keys)
noto-fonts-cjk
noto-fonts-emoji
nvtop (like htop but for GPU)
ripgrep (modern alt to grep)
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

`/etc/systemd/network/20-ethernet.network`:
```
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
DNS=::1 127.0.0.1
# MulticastDNS=yes
# IPv6PrivacyExtensions=yes

[DHCPv4]
UseDNS=no
RouteMetric=100

[DHCPv6]
UseDNS=no

[IPv6AcceptRA]
UseDNS=no
RouteMetric=100

[Route]
Gateway=_dhcp4
InitialCongestionWindow=30
InitialAdvertisedReceiveWindow=30

[Route]
Gateway=_ipv6ra
InitialCongestionWindow=30
InitialAdvertisedReceiveWindow=30
```

`/etc/systemd/network/25-wlan.network`:
```
# https://man.archlinux.org/man/systemd.network.5
# https://www.freedesktop.org/software/systemd/man/systemd.network.html

[Match]
Name=wlan*

[Network]
DHCP=yes
IgnoreCarrierLoss=3s
DNS=::1 127.0.0.1

[DHCPv4]
UseDNS=no
RouteMetric=600

[DHCPv6]
UseDNS=no

[IPv6AcceptRA]
UseDNS=no
RouteMetric=600

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
    iifname { "lo", "tun0", "wg0", "wg1", "wg2", "wg3" } accept
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
    oifname { "lo", "tun0", "wg0", "wg1", "wg2", "wg3" } accept

    meta nfproto ipv4 ip daddr @wireguard_ips udp dport 51820 accept
    #meta nfproto ipv4 ip daddr @openvpn_ips th dport @openvpn_ports accept

    # Allow local traffic
    #ip daddr 192.168.0.0/16 oifname != { "tun0", "wg0" } accept
    #ip6 daddr fe80::/10 oifname != { "tun0", "wg0" } accept

    # Allow syncthing ports (for local network sync)
    #tcp dport 22000 accept
    #udp dport 22000 accept
  }
}

table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100
    oifname { "tun0", "wg0", "wg1", "wg2", "wg3" } masquerade
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

`/boot/loader/entries/linux-mws.conf`:
```
title Linux MWS
options root=UUID=a02dc858-2894-4a72-95c0-6afe83682efa rw zswap.enabled=0 mitigations=off nowatchdog
linux /vmlinuz-linux-cachyos
initrd /initramfs-linux-cachyos.img

```

### Network Performance Tweaks

```sh
# TCP BBR
echo "tcp_bbr" | tee /etc/modules-load.d/net.conf

tee /etc/sysctl.d/99-network-performance.conf <<EOF
# BBR
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# TCP
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_slow_start_after_idle = 0

# Large socket buffers
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Increase ephemeral port range
net.ipv4.ip_local_port_range = 2000 65535

# Handle burst traffic
net.core.netdev_budget = 600
net.core.netdev_max_backlog=25000
net.ipv4.tcp_max_syn_backlog=8192
net.core.somaxconn=65535

# Connection tracking for high concurrency
net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 7200
EOF

sysctl --system
```

`/etc/security/limits.conf`:
```
* soft nofile 65536
* hard nofile 1048576
```

`/etc/udev/rules.d/10-network-eth.rules`:
```
ACTION=="add", SUBSYSTEM=="net", KERNEL=="enp*", RUN+="/usr/bin/ethtool -K %k tx on rx on sg on tso on ufo on gso on gro on lro on rxvlan on txvlan on"
```

<!--
```sh
# Increase ring buffer sizes (adjust interface name)
ethtool -G enp0s3 rx 4096 tx 4096

# Enable adaptive interrupt coalescing
ethtool -C enp0s3 adaptive-rx on adaptive-tx on

# Consider enabling receive packet steering on multi-core systems
echo 'SUBSYSTEM=="net", ACTION=="add", KERNEL=="enp*", RUN+="/bin/bash -c \''echo 7 > /sys/class/net/%k/queues/rx-0/rps_cpus\''"' | sudo tee /etc/udev/rules.d/60-net-rps.rules
```
-->
