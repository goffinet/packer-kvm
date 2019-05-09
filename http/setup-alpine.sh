#!/bin/sh

set -x

setup-keymap us us

setup-interfaces -i <<EOF
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
EOF

echo "root:testtest" | chpasswd

setup-apkrepos http://dl-cdn.alpinelinux.org/alpine/v3.9/main

apk add --quiet openssh
rc-update --quiet add sshd default
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

apk add --quiet syslinux

rc-update --quiet add networking boot
rc-update --quiet add urandom boot

ERASE_DISKS=/dev/vda setup-disk -s 0 -m sys /dev/vda

extlinux --install /mnt/boot
sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf

reboot
