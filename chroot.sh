#!/bin/env bash

xbps-remove -y sudo gzip nvi less wpa_supplicant linux-firmware-broadcom linux-firmware-intel

cd /usr/local
rm -rf sbin
ln -s bin sbin

cd /usr/bin
ln -s pigz gzip
ln -s unpigz gunzip

/bin/bash
