#!/bin/env bash

cd $( dirname "${BASH_SOURCE[0]}" ) || exit 1
. config.sh || exit 1
 
uefi_uuid=$(blkid -s UUID -o value $efi_partition)
luks_uuid=$(cryptsetup luksUUID $sys_partition)
crypt_name=$(lsblk -J $sys_partition | jq -r '.blockdevices[0].children[] | select(.type=="crypt") | .name')
sys_uuid=$(blkid -s UUID -o value /dev/mapper/$crypt_name)
sys_label=$(blkid -s LABEL -o value /dev/mapper/$crypt_name)

kernel_cmdline=(
	rw
    quiet
	rd.luks.timeout=60
	rd.luks.crypttab=no
    rd.luks.allow-discards=
    rd.luks.uuid=
	rd.luks.name=$luks_uuid=$sys_label
	root=UUID=$sys_uuid
	rootflags=subvol=@
)

# variant
#rd.luks.uuid=__UUID__HERE__ 
#rd.luks.name=__UUID_HERE__=root 
#rootfstype=btrfs 
#rootflags=__MOUNT_FLAGS__

# variant2
#cryptdevice=UUID=<UUID>:luks 
#root=/dev/mapper/luks 
#luks=UUID=<uuid> 
#rw 
#rootflags=subvol=@ initrd=amd-ucode.img initrd=initramfs-%v.img 
#add_efi_memmap

# install additional packages, mostly system-based, TUI-only 
xbps-install -Suvy opendoas micro moar iwd socklog-void cryptsetup rsv \
  dbus pam apparmor turnstile seatd polkit iptables-nft \
  refind dracut-uefi systemd-boot-efistub terminus-font zstd \
  vpm vsv \
  git git-crypt yadm smartmontools \
  zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zr
#sbsigntool efitools

# LUKS keyfile
dd bs=512 count=4 if=/dev/urandom of=/boot/$crypt_name.keyfile
cryptsetup luksAddKey /dev/sda1 /boot/$crypt_name.keyfile

# essential configs
printf "hostname=$hostname\n" >/etc/hostname

sed -i "/#TIMEZONE=/s/.*/TIMEZONE=$tz/" /etc/rc.conf
sed -i "/#KEYMAP=/s/.*/KEYMAP=$keymap/" /etc/rc.conf
sed -i "/#FONT=/s/.*/FONT=$font/" /etc/rc.conf

sed -i "/^SHELL=/s/=.*/=\/bin\/$interactive_shell/" /etc/default/useradd

cat <<EOF >/etc/dracut.conf.d/host.conf
hostonly=yes
hostonly_cmdline=no
use_fstab=yes
compress=zstd
show_modules=yes
add_dracutmodules+=" dm btrfs crypt "  
install_items+=/boot/keys/keyfile
filesystems+=" btrfs "
uefi=yes
early_microcode=yes
uefi_stub=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
kernel_cmdline="${kernel_cmdline[*]}"
EOF

cat <<EOF >/etc/dracut.conf.d/i18n.conf
i18n_vars="/etc/rc.conf:KEYMAP,FONT"
i18n_install_all=no
EOF

cat <<EOF >/etc/doas.conf
permit persist :wheel
permit setenv {PATH=/usr/local/bin:/bin} :wheel
permit nopass :plugdev as root cmd /bin/smartctl
permit nopass :wheel as root cmd /bin/reboot
permit nopass :wheel as root cmd /bin/shutdown
EOF
chmod -c 0400 /etc/doas.conf

cat <<EOF >/etc/fstab
UUID=$sys_uuid / btrfs $btrfs_opt,subvol=@ 0 1
UUID=$sys_uuid /home btrfs $btrfs_opt,subvol=@home 0 2
UUID=$sys_uuid /.snapshots btrfs $btrfs_opt,subvol=@snapshots 0 2
UUID=$uefi_uuid /boot/efi vfat defaults,noatime 0 2
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
EOF


# services
for srv in acpid dbus iwd nanoklogd polkitd seatd socklog-unix turnstiled; do
  ln -s /etc/sv/$srv /etc/runit/runsvdir/default/$srv
done

# uki
dracut --regenerate-all --force

# bootloader
refind-install

# new user
useradd --create-home --groups wheel,users,audio,video,input,plugdev $newuser
passwd --expire $newuser

printf "Changing root password\n"
passwd




