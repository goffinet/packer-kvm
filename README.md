# packer-kvm

Create VM templates for usage with libvirt/KVM virtualization.

Only for education and learning purposes.

This is a Packer Proof of Concept/sample with :

* qemu/kvm as builder
* shell and ansible-local as provisionners
* shell-local as post-processor

Optionnal :

* inside a docker container

## Build

Pre-requisites :

* libvirt/KVM
* Packer (in /opt/packer)

```bash
packer build centos7.json
```

```bash
packer build ubuntu1804.json
```

## Build with Docker qemu based image

`goffinet/packer-qemu` is a Docker image for building qemu images with packer


```bash
docker run --rm                                     \
  -e PACKER_LOG=1                                   \
  -e PACKER_LOG_PATH="packer-docker.log"            \
  -it                                               \
  --privileged                                      \
  --cap-add=ALL -v /lib/modules:/lib/modules        \
  -v `pwd`:/opt/                                    \
  -v $HOME/.ssh/id_rsa:/root/.ssh/id_rsa            \
  -w /opt/ goffinet/packer-qemu build centos7.json
```

To build the image localy with the [Dockerfile](Dockerfile) :

```shell
docker build -t packer-qemu .
```

## Exploit with Libvirt

[https://github.com/goffinet/virt-scripts](https://github.com/goffinet/virt-scripts)

## Credits

* [https://github.com/idi-ops/packer-kvm-centos](https://github.com/idi-ops/packer-kvm-centos)
* [https://github.com/leonkyneur/packer-qemu](https://github.com/leonkyneur/packer-qemu)

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
