#!/bin/env bash

efi_partition=/dev/nvme0n1p1
tank_partition=/dev/nvme0n1p2
crypt_name=cryptotank

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/btrfs_opt.sh

NORMAL="\e[0m"
RED_LIGHT="\e[1;31m"

function error {
  echo -e -n "\n${RED_LIGHT}$1${NORMAL}\n\n"
  exit 1
}

if findmnt /mnt &>/dev/null; then
  echo "Already mounted\n"
else
  tank_disk=/dev/mapper/$crypt_name
  if [[ ! -L $tank_disk ]]; then
    cryptsetup open $tank_partition $crypt_name --verbose --batch-mode ||
      error "Can't open crypted tank"
  fi  
  mount -o $btrfs_opt,subvol=@ $tank_disk /mnt ||
    error "Can't mount subvol @"
  mount -o $btrfs_opt,subvol=@home $tank_disk /mnt/home/ ||
    error "Can't mount subvol @home"
  mount -o noatime $efi_partition /mnt/boot/efi ||
    error "Can't mount efi partition"
fi
[[ $1 == "wipe" ]] && rm -rf /mnt/* &>/dev/null && echo "Wiped!\n"




