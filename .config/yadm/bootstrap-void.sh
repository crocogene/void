#!/bin/env bash

# Modified void bootstrap script
# based on https://github.com/negativeExponent/dotfiles

set -e

BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
ALL_OFF="\033[0m"

REPO='https://repo-fastly.voidlinux.org/' # Worldwide

error() {
  printf "${BOLD}${RED}ERROR:${ALL_OFF}${BOLD} %s${ALL_OFF}\n" "$1" >&2
  exit 1
}

info() {
	printf "${BOLD}${GREEN}==>${ALL_OFF}${BOLD} %s${ALL_OFF}\n" "$1" ;
}

xbps_install() {
	sudo xbps-install -y -R ${REPO}/current -R ${REPO}/current/nonfree "$@"
}

install_packages() {
	sed -e "/^#/d" -e "s/#.*//" ${HOME}/.config/yadm/pkglist-void | while read pkg; do
		xbps_install $pkg || error "Failed installation."
	done
}

configure_services() {	
	dir="/etc/runit/runsvdir/default/"

	# remove unnecessary services
	remove_svc="acpi agetty-tty3 agetty-tty4 agetty-tty5 agetty-tty6 dhcpcd sshd"
	for svc in $remove_svc
	do
		if [ -d /var/service/$svc ] ; then
			info "Removing service $svc"
			sudo rm /var/service/$svc
		fi
	done

    # enable services
	common_srcs="dhcpcd crond dbus elogind ntpd polkitd socklog-unix nanoklogd udevd runit-swap"
	for svc in $common_srcs
	do
		if [ -d /etc/sv/$svc ] && ! [ -d /var/service/$svc ] ; then
			info "Enabling service: $svc"
			sudo ln -sf /etc/sv/$svc $dir
		fi
	done

	grep socklog /etc/group >/dev/null && sudo usermod -a -G socklog "$USER"
}

configure_fonts() {	
	sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
	sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
	sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
	sudo ln -sf /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
	# sudo ln -sf /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/

	sudo xbps-reconfigure -f fontconfig
}

cleanup() {
}

########
# main #
########

info "************************"
info "Installing VoidLinux...."
info "************************"

info "Updating xbps database..."
echo y | sudo xbps-install -Su || error "Failed to update system!"

info "Installing packages..."
install_packages || error "Failed to install packages!"

info "Configure runit services..."
configure_services || error "Failed to configure runit services!"

info "Configure fonts..."
configure_fonts || error "Failed to configure fonts!"

info "Finalizing and cleanup..."
cleanup

info "============"
info "= Finished ="
info "============"