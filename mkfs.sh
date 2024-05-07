#!/bin/env bash

efi_partition=/dev/nvme0n1p1
efi_name=EFI
tank_partition=/dev/nvme0n1p2
crypt_name=cryptotank
tank_label=tank

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/btrfs_opt.sh

NORMAL="\e[0m"
RED_LIGHT="\e[1;31m"

error () {
  echo -e -n "\n\n${RED_LIGHT}$1${NORMAL}\n\n"
  exit 1
}

# EFI
mkfs.vfat -n $efi_name -F 32 $efi_partition \ 
  || error "Can't create the vfat filesystem on efi partition"

# Tank
tank_disk=/dev/mapper/$crypt_name
if findmnt /mnt &>/dev/null; then
  umount --recursive --force /mnt
fi
if [[ -L $tank_disk ]]; then
  cryptsetup close $crypt_name --batch-mode \
    || error "Can't remove the existing $tank_disk"
fi
cryptsetup luksFormat --type=luks2 $tank_partition --verbose --batch-mode \ 
  || error "Can't initialize LUKS on $tank_partition"
cryptsetup open $tank_partition $crypt_name --verbose --batch-mode \
  || error "Can't setup a mapping $tank_disk"
mkfs.btrfs --force -L $tank_label $tank_disk \
  || error "Can't create the btrfs filesystem on $tank_disk"
mount -o $btrfs_opt $tank_disk /mnt \
  || error "Can't mount $tank_disk to /mnt"
btrfs subvolume create /mnt/@ \
  || error "Can't create subvol @"
btrfs subvolume create /mnt/@home \
  || error "Can't create subvol @home"
btrfs subvolume create /mnt/@snapshots \
  || error "Can't create subvol @snapshots"
umount /mnt
mount -o $btrfs_opt,subvol=@ $tank_disk /mnt
mkdir -p /mnt/{boot/efi,home,var,.snapshots}
mount -o $btrfs_opt,subvol=@home $tank_disk /mnt/home/
btrfs subvolume create /mnt/var/cache \
  || error "Can't create subvol /var/cache"
btrfs subvolume create /mnt/var/log \
  || error "Can't create subvol /var/log"
btrfs subvolume create /mnt/var/tmp \
  || error "Can't create subvol /var/tmp"
mount -o noatime $efi_partition /mnt/boot/efi \
  || error "Can't mount efi partition"




