#!/bin/env bash

REPO=https://repo-de.voidlinux.org/current/musl
ARCH=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
cp -a "$SCRIPT_DIR"/etc/xbps.d/. /etc/xbps.d/
XBPS_ARCH=$ARCH xbps-install -S -y -r /mnt -R "$REPO" base-system
cp -a "$SCRIPT_DIR"/etc/. /mnt/etc/
cp -r "$SCRIPT_DIR" /mnt/root/
BTRFS_OPT="$BTRFS_OPT" xchroot /mnt /bin/bash /root/void/chroot.sh
