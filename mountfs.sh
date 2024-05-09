#!/bin/env bash

cd $( dirname "${BASH_SOURCE[0]}" ) || exit 1
. config.sh || exit 1

findmnt /mnt &>/dev/null && error "Already mounted"

if [[ ! -L $sys_disk ]]; then
  cryptsetup open $sys_partition $crypt_name --verbose --batch-mode ||
    error "Can't setup a mapping $sys_disk"
fi  
mount -o $btrfs_opt,subvol=@ $sys_disk /mnt ||
  error "Can't mount subvol @"
mount -o $btrfs_opt,subvol=@home $sys_disk /mnt/home/ ||
  error "Can't mount subvol @home"
mount -o noatime $efi_partition /mnt/boot/efi ||
  error "Can't mount efi partition"






