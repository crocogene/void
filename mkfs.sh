#!/bin/env bash

efi_partition=/dev/nvme0n1p1
efi_name=EFI
tank_partition=/dev/nvme0n1p2
crypt_name=cryptotank
tank_label=tank
swap_partition=

# EFI
mkfs.vfat -n "$efi_name" -F 32 "$efi_partition"

# Tank
tank_disk="/dev/mapper/$crypt_name"
if [[ -f "$tank_disk" ]]; then
  cryptsetup close "$tank_disk"
fi
wipefs -a "$tank_partition"
cryptsetup luksFormat --type=luks2 "$tank_partition" --verbose --batch-mode
cryptsetup open "$tank_partition" "$crypt_name"
mkfs.btrfs --force -L "$tank_label" "$tank_disk"
export BTRFS_OPT=compress-force=zstd:1,noatime,discard=async,commit=120
mount -o "$BTRFS_OPT" "$tank_disk" /mnt
btrfs subvolume create /mnt/{@,@home,@snapshots}
umount /mnt
mount -o "$BTRFS_OPT",subvol=@ "$tank_disk" /mnt
mkdir /mnt/{home,var}
mount -o "$BTRFS_OPT",subvol=@home "$tank_disk" /mnt/home/
btrfs subvolume create /mnt/var/{cache,log,tmp}

# Swap



