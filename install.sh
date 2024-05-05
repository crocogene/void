#!/bin/env bash

REPO=https://repo-de.voidlinux.org/current/musl
ARCH=x86_64-musl

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
XBPS_ARCH=$ARCH xbps-install -S -y -r /mnt -R "$REPO" base-system opendoas pigz moar micro iwd
cp -r "$SCRIPT_DIR"/etc/. /mnt/etc/
cp "$SCRIPT_DIR"/chroot.sh /mnt/root/
xchroot /mnt /bin/bash /root/chroot.sh
