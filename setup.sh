#!/bin/bash

if [ "$EUID" -ne 0 ] ; then echo "Please run as root" ; exit ; fi

if [ $AWS_ACCESS_KEY == "" ] ; then
read -p "Entrez votre AWS_ACCESS_KEY : " AWS_ACCESS_KEY
read -p "Entrez votre AWS_SECRET_KEY : " AWS_SECRET_KEY
fi

1_virtualization_installation () {
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y upgrade
apt-get -y install wget unzip
apt-get -y install qemu-kvm libvirt-dev virtinst virt-viewer libguestfs-tools virt-manager uuid-runtime curl linux-source libosinfo-bin
virsh net-start default
virsh net-autostart default
elif [ -f /etc/redhat-release ]; then
yum -y install wget unzip
yum -y install epel-release
yum -y upgrade
yum -y group install "Virtualization Host"
yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer virt-manager curl
ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64
fi
}

2_packer_installation () {

currentd=$PWD
cd /tmp
latest=$(curl -L -s https://releases.hashicorp.com/packer | grep 'packer_' | sed 's/^.*<.*\">packer_\(.*\)<\/a>/\1/' | head -1)
wget https://releases.hashicorp.com/packer/${latest}/packer_${latest}_linux_amd64.zip
unzip packer*.zip
chmod +x packer
mv packer /usr/local/bin/
cd $currentd
}

1_virtualization_installation
2_packer_installation
