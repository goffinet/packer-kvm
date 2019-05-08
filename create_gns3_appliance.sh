#!/bin/bash

packer_image=$1
name=$2
version=$3

cp ${packer_image} /tmp/${name}${version}.qcow2
md5sum_image=$(md5sum /tmp/${name}${version}.qcow2 | cut -d' ' -f1)
size_image=$(stat -c %s /tmp/${name}${version}.qcow2)

cat << EOF > ${name}${version}.gns3a
{
    "name": "${name}",
    "category": "guest",
    "description": "${name} ${version} image",
    "vendor_name": "centos",
    "vendor_url": "https://get.goffinet.org/kvm",
    "product_name": "centos",
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
