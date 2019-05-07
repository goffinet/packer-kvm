# packer-kvm-centos

Create VM templates for usage with libvirt/KVM virtualization

## Rationale

This packer repository differs significantly from [idi-ops/packer-centos](https://github.com/idi-ops/packer-centos), which is to be consumed by developers. At the cost of some code duplication, spagetthi code and unnecessary complexity is avoided by having separate repositories. Additionally, improvements can be made independently without fear of breaking the production-grade CentOS image with changes that only make sense for CentOS Vagrant boxes, and vice-versa.

# Pre-requisites

 * libvirt/KVM
 * Packer (in /opt/packer)


## Build

```
$ packer build centos7.json
```

## Credits

[https://github.com/idi-ops/packer-kvm-centos](https://github.com/idi-ops/packer-kvm-centos)
