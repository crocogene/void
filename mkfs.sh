#!/bin/env bash

cd $( dirname "${BASH_SOURCE[0]}" ) || exit 1
. config.sh || exit 1

findmnt /mnt &>/dev/null && umount --recursive --force /mnt

dd if=/dev/urandom of=btrfs-new.keyfile bs=256 count=1
chmod 400 btrfs-new.keyfile

if [[ -L $sys_disk ]]; then
  if [[ $1 == "reencrypt" ]]; then 
    cryptsetup reencrypt $sys_disk --batch-mode ||
      error "Can't reencrypt $sys_disk"
  fi    
else
  #dd if=/dev/urandom of=$sys_partition
  badblocks -c 10240 -s -w -t random -v $sys_partition ||
    error "Can't fill $sys_partitioin with a random data"
  cryptsetup luksFormat --type=luks2 $sys_partition --verbose --batch-mode ||
    error "Can't initialize LUKS on $sys_partition"
  cryptsetup open $sys_partition $crypt_name --verbose --batch-mode ||
    error "Can't setup a mapping $sys_disk"
fi
mkfs.btrfs --force -L $sys_label $sys_disk ||
  error "Can't create the btrfs filesystem on $sys_disk"
mount -o $btrfs_opt $sys_disk /mnt ||
  error "Can't mount $sys_disk to /mnt"
btrfs subvolume create /mnt/@ ||
  error "Can't create subvol @"
btrfs subvolume create /mnt/@home ||
  error "Can't create subvol @home"
btrfs subvolume create /mnt/@snapshots ||
  error "Can't create subvol @snapshots"
umount /mnt
mount -o $btrfs_opt,subvol=@ $sys_disk /mnt
mkdir -p /mnt/{boot/efi,home,var,.snapshots}
mount -o $btrfs_opt,subvol=@home $sys_disk /mnt/home/
btrfs subvolume create /mnt/var/cache ||
  error "Can't create subvol /var/cache"
btrfs subvolume create /mnt/var/log ||
  error "Can't create subvol /var/log"
btrfs subvolume create /mnt/var/tmp ||
  error "Can't create subvol /var/tmp"

mkfs.vfat -n $efi_label -F 32 $efi_partition ||
  error "Can't create the vfat filesystem on efi partition"  
mount -o noatime $efi_partition /mnt/boot/efi ||
  error "Can't mount efi partition"




