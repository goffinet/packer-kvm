# packer-kvm

Create VM templates for usage with libvirt/KVM virtualization.

Only for education purposes.

Packer Proof of Concept with :

* qemu/kvm as builder
* shell and ansible-local as provisionners
* shell-local as post-processor

## Pre-requisites

 * libvirt/KVM
 * Packer (in /opt/packer)

## Build


```bash
packer build centos7.json
```

```bash
packer build ubuntu1804.json
```


## Credits

[https://github.com/idi-ops/packer-kvm-centos](https://github.com/idi-ops/packer-kvm-centos)

## Notes

Ubuntu 18.04

```json
      "boot_command": [
        "<enter><wait><f6><esc><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
        "/install/vmlinuz ",
        "initrd=/install/initrd.gz ",
        "net.ifnames=0 ",
        "auto-install/enable=true ",
        "debconf/priority=critical ",
        "preseed/url=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu1804-preseed.cfg",
        "<enter>"
      ],
```
