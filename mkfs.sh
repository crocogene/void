#!/bin/env bash

efi_partition=/dev/nvme0n1p1
efi_name=EFI
tank_partition=/dev/nvme0n1p2
crypt_name=cryptotank
tank_label=tank
swap_partition=
. btrfs_opt

# EFI
mkfs.vfat -n "$efi_name" -F 32 "$efi_partition"

# Tank
tank_disk="/dev/mapper/$crypt_name"
if findmnt /mnt &>/dev/null; then
  umount --recursive --force /mnt
fi
if [[ -f "$tank_disk" ]]; then
  cryptsetup close "$crypt_name"
fi
#wipefs -a "$tank_partition"
cryptsetup luksFormat --type=luks2 "$tank_partition" --verbose --batch-mode
cryptsetup open "$tank_partition" "$crypt_name" --batch-mode
mkfs.btrfs --force -L "$tank_label" "$tank_disk"
mount -o "$BTRFS_OPT" "$tank_disk" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt
mount -o "$BTRFS_OPT",subvol=@ "$tank_disk" /mnt
mkdir /mnt/{home,var}
mount -o "$BTRFS_OPT",subvol=@home "$tank_disk" /mnt/home/
btrfs subvolume create /mnt/var/cache
btrfs subvolume create /mnt/var/log
btrfs subvolume create /mnt/var/tmp

# Swap



