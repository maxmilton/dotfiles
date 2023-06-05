#!/bin/sh -eu

busybox_path=$(type -p busybox)

if test -z "$busybox_path"; then
    echo "busybox not found"
    exit 1
fi

ln -vsf "$busybox_path" /usr/local/bin/bc
ln -vsf "$busybox_path" /usr/local/bin/dos2unix
ln -vsf "$busybox_path" /usr/local/bin/hexedit
ln -vsf "$busybox_path" /usr/local/bin/httpd
ln -vsf "$busybox_path" /usr/local/bin/iostat
ln -vsf "$busybox_path" /usr/local/bin/lsof
ln -vsf "$busybox_path" /usr/local/bin/nc
ln -vsf "$busybox_path" /usr/local/bin/netstat
ln -vsf "$busybox_path" /usr/local/bin/vi
ln -vsf "$busybox_path" /usr/local/bin/wget
ln -vsf "$busybox_path" /usr/local/bin/whois
ln -vsf "$busybox_path" /usr/local/bin/xxd

# ln -vsf "$busybox_path" /usr/local/bin/ping
# ln -vsf "$busybox_path" /usr/local/bin/unzip
