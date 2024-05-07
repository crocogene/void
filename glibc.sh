#!/bin/env bash

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
echo "$xbps_glibc_params"
XBPS_ARCH="$arch_glibc" xbps-install "$xbps_glibc_params" void-repo-nonfree
XBPS_ARCH="$arch_glibc" xbps-install "$xbps_glibc_params" \
  glibc nvidia

# build and install glibc packages from source