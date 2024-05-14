#!/bin/env bash

efi_partition=/dev/nvme0n1p1
sys_partition=/dev/nvme0n1p2
efi_label=EFI
sys_label=system
crypt_name=cryptsystem
btrfs_opt=compress-force=zstd:1,noatime,discard=async,commit=120
efi_mountpoint=/efi

repo=https://repo-default.voidlinux.org/current/musl
arch=x86_64-musl

shell=zsh
hostname=void
keymap=us
font=ter-v28b
tz=Europe/Amsterdam
newuser=user

####################################
#      Don't edit lines below      #
####################################
sys_disk=/dev/mapper/$crypt_name

# Private settings overwriting (crypted)
. $( dirname "${BASH_SOURCE[0]}" )/.priv/config.sh

# Helpers
NORMAL="\e[0m"
RED_LIGHT="\e[1;31m"

error () {
  printf "\n${RED_LIGHT}$1${NORMAL}\n\n"
  exit 1
}

