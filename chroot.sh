#!/bin/env bash

hostname=void
keymap=us
tz=Europe/Istanbul
user=user
efi_partition=/dev/nvme0n1p1
crypt_name=cryptotank

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/btrfs_opt.sh

# install additional packages
xbps-install -Suvy opendoas micro moar iwd socklog-void refind pam-mount dbus \
  turnstile seatd yadm  

# essential configs
echo "hostname=$hostname" >/etc/hostname

## fstab
uefi_uuid=$(blkid -s UUID -o value $efi_partition)
tank_uuid=$(blkid -s UUID -o value /dev/mapper/$cryptname)
cat <<EOF > /etc/fstab
UUID=$tank_uuid / btrfs $btrfs_opt,subvol=@ 0 1
UUID=$tank_uuid /home btrfs $btrfs_opt,subvol=@home 0 2
UUID=$tank_uuid /.snapshots btrfs $btrfs_opt,subvol=@snapshots 0 2
UUID=$uefi_uuid /boot/efi vfat defaults,noatime 0 2
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
EOF


