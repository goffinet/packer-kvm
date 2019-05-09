#!/bin/sh

cat > alpine-answers <<EOF
KEYMAPOPTS="us us"
HOSTNAMEOPTS="-n alpine"
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
      hostname alpine
"
DNSOPTS="-d example.com 8.8.8.8"
TIMEZONEOPTS="-z UTC"
PROXYOPTS="none"
APKREPOSOPTS="-f"
SSHDOPTS="-c openssh"
NTPOPTS="-c openntpd"
DISKOPTS="-v -m sys /dev/vda"
EOF

setup-alpine -f alpine-answers <<EOF
$ROOT_PASSWORD
$ROOT_PASSWORD
y
EOF

rc-update --quiet add sshd default
apk add --quiet syslinux
sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf
apk add --quiet qemu-guest-agent python
rc-update --quiet add networking boot
rc-update --quiet add urandom boot
rc-update --quiet add qemu-guest-agent boot

setup-alpine -f alpine-answers <<EOF
$ROOT_PASSWORD
$ROOT_PASSWORD
y
EOF

# remount the device, change networking, install our ssh key
mount /dev/vda3 /mnt
echo "write someting in the FS"
umount /dev/vda3
