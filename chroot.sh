#!/bin/env bash

repo_glibc=https://repo-default.voidlinux.org/current
arch_glibc=x86_64

# install additional packages
xbps-install -Suvy moar iwd turnstile seatd socklog-void refind \
  mesa-dri vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau

# install glibc namespace
install -d /glibc/{var,usr/local/bin}
cd /glibc
ln -s /boot boot
ln -s /dev dev
ln -s /etc etc
ln -s /proc proc
ln -s /sys sys
ln -s /var/log var/log
cd /glibc/usr/local ; ln -s bin sbin # no separate local sbin needed

xbps_glibc_params="-Suvy -r /glibc -R $repo_glibc -C /etc/xbps-glibc.d"
XBPS_ARCH="$arch_glibc" xbps-install "$xbps_glibc_params" void-repo-nonfree
XBPS_ARCH="$arch_glibc" xbps-install "$xbps_glibc_params" \
  glibc nvidia

# make and install voidnsrun package

# make glibc voidnsundo scripts


