#!/bin/env bash

REPO=https://repo-de.voidlinux.org/current/musl
ARCH=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" base-system
mkdir /mnt/root
cp -r "$SCRIPT_DIR" /mnt/root/
BTRFS_OPT="$BTRFS_OPT" xchroot /mnt /bin/bash /root/void/chroot.sh
