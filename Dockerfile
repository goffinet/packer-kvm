FROM hashicorp/packer:light

RUN apk add --update qemu qemu-system-x86_64 qemu-img openssh python3 py3-pip samba
