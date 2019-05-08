#!/bin/bash

if $1 == "help" ; then
echo "help !"
fi 

if $1 == "centos" ; then
packer_image="artifacts/qemu/centos7-x86_64/packer-centos7-x86_64"
name="centos"
version="7.6"
output_path="artifacts/qemu"
fi

mv ${packer_image} ${output_path}/${name}${version}.qcow2
md5sum_image=$(md5sum ${output_path}/${name}${version}.qcow2 | cut -d' ' -f1)
size_image=$(stat -c %s ${output_path}/${name}${version}.qcow2)

cat << EOF > ${output_path}/${name}${version}.gns3a
{
    "name": "${name}${version}",
    "category": "guest",
    "description": "${name} ${version} image",
    "vendor_name": "${name}",
    "vendor_url": "https://get.goffinet.org/kvm",
    "product_name": "${name}",
    "registry_version": 1,
    "status": "stable",
    "maintainer": "goffinet@goffinet.org",
    "maintainer_email": "goffinet@goffinet.org",
    "usage": "Default password is user/root/testtest",
    "port_name_format": "eth{0}",
    "qemu": {
        "adapter_type": "virtio-net-pci",
        "adapters": 1,
        "ram": 512,
        "arch": "x86_64",
        "hda_disk_interface": "virtio",
        "console_type": "telnet",
        "kvm": "require"
    },
    "images": [
        {
            "filename": "${name}${version}.qcow2",
            "version": "${version}",
            "md5sum": "${md5sum_image}",
            "filesize": $size_image,
            "download_url": "https://get.goffinet.org/kvm/",
            "direct_download_url": "https://get.goffinet.org/kvm/${name}${version}.qcow2"
        }
    ],
    "versions": [
       {
            "name": "${name}${version}",
            "images": {
                "hda_disk_image": "${name}${version}.qcow2"
            }
        }
    ]
}
EOF
