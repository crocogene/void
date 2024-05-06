#!/bin/env bash

repo=https://repo-default.voidlinux.org/current/musl
arch=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# /mnt preparations
install -d /mnt/var/db/xbps/keys /mnt/etc/ /mnt/usr/{bin,local/bin}

cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys            # xbps keys from live iso
#cp -r "$SCRIPT_DIR"/etc/. /mnt/etc/                     # configs from this git repo
for 

cd /mnt/usr/local ; ln -s bin sbin                      # no separate local sbin needed
cd /mnt/usr/bin ; ln -s pigz gzip ; ln -s unpigz gunzip # gzip-pigz shim

# install only essential packages 
XBPS_ARCH="$arch" xbps-install -Suvy -r /mnt -R "$repo" \
  base-container pam-mount pigz micro

# enter chroot environment, run init script and stay in bash interactive session until exit command
ln -s "$SCRIPT_DIR"/chroot.sh /mnt/root/chroot.sh
xchroot /mnt /bin/bash -i /root/chroot.sh

# cleanup 
rm /mnt/root/chroot.sh
umount --recursive --force /mnt

