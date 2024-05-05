#!/bin/env bash

repo=https://repo-default.voidlinux.org/current
arch=x86_64

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

mkdir /mnt/etc
cp -r "$SCRIPT_DIR"/etc/. /mnt/etc/

XBPS_ARCH="$arch"-musl xbps-install -Suvy -r /mnt -R "$repo"/musl -S \
  base-system pam-mount opendoas pigz micro moar iwd \
  turnstile seatd socklog-void \
  mesa-dri 

cd /mnt/usr/local ; rm -rf sbin ; ln -s bin sbin
cd /mnt/usr/bin ; ln -s pigz gzip ; ln -s unpigz gunzip

mkdir -p /mnt/glibc/var
cd /mnt/glibc
ln -s /dev dev
ln -s /etc etc
ln -s /proc proc
ln -s /sys sys
ln -s /var/log var/log
ln -s /boot boot
XBPS_ARCH="$arch" xbps-install -Suvy -r /mnt/glibc -R "$repo" -S \
#  base-container \
  nvidia

cd /mnt/glibc/usr/local ; rm -rf sbin ; ln -s bin sbin

cp "$SCRIPT_DIR"/chroot.sh /mnt/root/
xchroot /mnt /bin/bash 

umount --recursive --force /mnt

