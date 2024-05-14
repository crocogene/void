#!/bin/env bash

cd $( dirname "${BASH_SOURCE[0]}" ) || exit 1
. config.sh || exit 1
 
uefi_uuid=$(blkid -s UUID -o value $efi_partition)
luks_uuid=$(blkid -s UUID -o value $sys_partition)
sys_uuid=$(blkid -s UUID -o value $sys_disk)

kernel_cmdline=(
	rw
	quiet
	loglevel=3
	udev.log_level=3
	rd.luks.uuid=$luks_uuid
	root=$sys_disk
	rootflags=subvol=@
	add_efi_memmap
	bgrt_disable
	fbcon=nodefer
	splash
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
xbps-install -Suvy opendoas micro moar iwd socklog-void cryptsetup zstd \
	dbus pam apparmor turnstile seatd polkit iptables-nft \
	gummiboot gummiboot-efistub plymouth dracut dracut-uefi efitools sbsigntool sbctl \
	vpm vsv rsv terminus-font \
	git git-crypt yadm \
	zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zr

printf "Changing root password\n"
passwd
chsh -s /bin/bash

sbctl create-keys

# essential configs
printf "hostname=$hostname" >/etc/hostname

sed -i "/#TIMEZONE=/s/.*/TIMEZONE=$tz/" /etc/rc.conf
sed -i "/#KEYMAP=/s/.*/KEYMAP=$keymap/" /etc/rc.conf
sed -i "/#FONT=/s/.*/FONT=$font/" /etc/rc.conf

sed -i "/^SHELL=/s/=.*/=\/bin\/$shell/" /etc/default/useradd

cat <<EOF >/etc/dracut.conf.d/main.conf
hostonly=yes
hostonly_cmdline=no
use_fstab=yes
compress=zstd
show_modules=yes
add_dracutmodules+=" dm btrfs "
filesystems+=" btrfs "
early_microcode=yes
uefi=yes
uefi_stub=/usr/lib/gummiboot/linuxx64.efi.stub
EOF

cat <<EOF >/etc/dracut.conf.d/kernel.conf
kernel_cmdline="${kernel_cmdline[*]}"
EOF

cat <<EOF >/etc/dracut.conf.d/i18n.conf
i18n_vars="/etc/rc.conf:KEYMAP,FONT"
i18n_install_all=no
EOF

cat <<EOF >/etc/dracut.conf.d/secureboot.conf
uefi_secureboot_cert=/usr/share/secureboot/keys/db/db.pem
uefi_secureboot_key=/usr/share/secureboot/keys/db/db.key
EOF

cat <<EOF >/etc/doas.conf
permit persist :wheel
permit setenv {PATH=/usr/local/bin:/bin} :wheel
permit nopass :wheel as root cmd /bin/reboot
permit nopass :wheel as root cmd /bin/shutdown
EOF
chmod -c 0400 /etc/doas.conf

cat <<EOF >/etc/fstab
UUID=$sys_uuid / btrfs $btrfs_opt,subvol=@ 0 1
UUID=$sys_uuid /home btrfs $btrfs_opt,subvol=@home 0 2
UUID=$sys_uuid /.snapshots btrfs $btrfs_opt,subvol=@snapshots 0 2
UUID=$uefi_uuid $efi_mountpoint vfat defaults,noatime 0 2
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
EOF

# services
for srv in acpid dbus iwd nanoklogd polkitd seatd socklog-unix turnstiled; do
	ln -s /etc/sv/$srv /etc/runit/runsvdir/default/$srv
done

exit

# uki
dracut --regenerate-all --force

# bootloader
refind-install

# new user
useradd --create-home --groups wheel,users,audio,video,input,plugdev $newuser
passwd --expire $newuser

