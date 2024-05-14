#!/bin/env bash

cd $( dirname "${BASH_SOURCE[0]}" ) || exit 1
. config.sh || exit 1

# Checks
findmnt /mnt &>/dev/null || error "/mnt is not mounted"
[[ -L $sys_disk ]] || error "Can't find $sys_disk"

# /mnt preparations
install -d /mnt/var/db/xbps/keys /mnt/etc/xbps.d /mnt/usr/{bin,local/bin}

cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys              # xbps keys from live iso
ln -s -r /mnt/usr/local/bin /mnt/usr/local/sbin           # no separate local sbin needed
ln -s -r /mnt/usr/bin/pigz /mnt/usr/bin/gzip              # gzip-pigz shim
ln -s -r /mnt/usr/bin/unpigz /mnt/usr/bin/gunzip          # gzip-pigz shim

for pkg in gzip sudo nvi less wpa_supplicant linux-firmware-broadcom linux-firmware-intel; do
	printf "ignorepkg=$pkg\n" >>/mnt/etc/xbps.d/ignore.conf
done

# install essential packages except ignored
# TODO jq->jaq
XBPS_ARCH=$arch xbps-install -Suvy -r /mnt -R $repo \
	base-system pigz

# run init script in the chroot environment
cp -v *.sh /mnt/root/
cp -v -r .private /mnt/root/
xchroot /mnt /bin/bash /root/chroot.sh

# enter chroot interactive mode until exit command
xchroot /mnt /bin/bash

# cleanup 
rm -rf /mnt/root/*
umount --recursive --lazy --verbose /mnt
