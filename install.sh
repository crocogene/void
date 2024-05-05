#!/bin/env bash

REPO=https://repo-de.voidlinux.org/current/musl
ARCH=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
mkdir /mnt/etc
cp -r "$SCRIPT_DIR"/etc/. /mnt/etc/
XBPS_ARCH=$ARCH xbps-install -S -y -r /mnt -R "$REPO" base-system opendoas pigz micro moar iwd
#xbps-remove -y -r /mnt sudo gzip nvi less wpa_supplicant
#xbps-remove -y -r /mnt linux-firmware-{broadcom,intel}
cd /mnt/usr/local ; rm -rf sbin ; ln -s bin sbin
cd /mnt/usr/bin ; ln -s pigz gzip ; ln -s unpigz gunzip

cp "$SCRIPT_DIR"/chroot.sh /mnt/root/
BTRFS_OPT="$BTRFS_OPT" PS1="$PS1" xchroot /mnt /bin/bash /root/chroot.sh
