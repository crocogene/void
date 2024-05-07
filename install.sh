#!/bin/env bash

repo=https://repo-default.voidlinux.org/current/musl
arch=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# /mnt preparations
install -d /mnt/var/db/xbps/keys /mnt/etc/xbps.d /mnt/usr/{bin,local/bin}

cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys            # xbps keys from live iso
cd /mnt/usr/local ; ln -s bin sbin                      # no separate local sbin needed
cd /mnt/usr/bin ; ln -s pigz gzip ; ln -s unpigz gunzip # gzip-pigz shim

while read p; do
  echo "ignorepkg=$p\n" >>/mnt/etc/xbps.d/ignore.conf
done <pkglist-ignore

# install essential packages except ignored
XBPS_ARCH=$arch xbps-install -Suvy -r /mnt -R $repo \
  base-system pigz

# run init script in the chroot environment
ln -s $SCRIPT_DIR/chroot.sh /mnt/root/chroot.sh
ln -s $SCRIPT_DIR/btrfs_opt.sh /mnt/root/btrfs_opt.sh
xchroot /mnt /bin/bash /root/chroot.sh
# enter chroot interactive until exit command
xchroot /mnt /bin/bash

# cleanup 
unlink /mnt/root/chroot.sh
umount --recursive --force /mnt

