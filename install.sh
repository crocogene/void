#!/bin/env bash

repo=https://repo-default.voidlinux.org/current/musl
arch=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# /mnt preparations
install -v -D -t /mnt/var/db/xbps/keys /var/db/xbps/keys/.

install -v -D -t /mnt/etc/ "$SCRIPT_DIR"/etc/.

install -d /mnt/usr/{bin,local/bin}
cd /mnt/usr/local ; ln -s bin sbin        # no separate local sbin needed
cd /mnt/usr/bin ; ln -s pigz gzip ; ln -s unpigz gunzip # gzip-pigz shim

# install only essential packages 
XBPS_ARCH="$arch" xbps-install -Suvy -r /mnt -R "$repo" \
  base-system pam-mount opendoas pigz micro

# enter chroot environment, run init script and stay in bash interactive session until exit command
cp "$SCRIPT_DIR"/chroot.sh /mnt/root/
xchroot /mnt /bin/bash -i /root/chroot.sh

# cleanup 
rm /mnt/root/chroot.sh
umount --recursive --force /mnt

