# packer-kvm

Create VM templates with Packer for usage with Libvirt/KVM virtualization : centos 7, bioinc (ubuntu 1804), debian 10 (stable).

Only for education and learning purposes.

## Introduction

This is a Packer Proof of Concept/sample with :

* qemu/kvm as builder
* shell and ansible-local as provisionners
* shell-local as post-processor to generate a [gns3a appliance file](https://docs.gns3.com/1MAdxz0BSEAfGM7tA-w-o3TMmf8XOx7nBf0z6d9nRz_c/index.html), checksum and upload to a server

Optionnal :

* inside a docker container

## Pre-requisites

* libvirt/KVM and Packer
* aws s3 cli
* Docker

### AWS S3

```bash
echo "export AWS_ACCESS_KEY=<your AWS_ACCESS_KEY>" >> ~/.profile
echo "export AWS_ACCESS_KEY=<your AWS_ACCESS_KEY"> >> ~/.profile
source ~/.profile
```

### Libvirt

```bash
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y upgrade
apt-get -y install qemu-kvm libvirt-dev virtinst virt-viewer libguestfs-tools virt-manager uuid-runtime curl linux-source libosinfo-bin
virsh net-start default
virsh net-autostart default
elif [ -f /etc/redhat-release ]; then
yum -y install epel-release
yum -y upgrade
yum -y group install "Virtualization Host"
yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer virt-manager curl
fi
```

### Packer

```bash
sudo yum -y install wget unzip || sudo apt update && sudo apt -y install wget unzip
latest=$(curl -L -s https://releases.hashicorp.com/packer | grep 'packer_' | sed 's/^.*<.*\">packer_\(.*\)<\/a>/\1/' | head -1)
wget https://releases.hashicorp.com/packer/${latest}/packer_${latest}_linux_amd64.zip
unzip packer*.zip
chmod +x packer
sudo mv packer /usr/local/bin/
```

### Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
```

## Build with Packer


```bash
packer build centos7.json
```

```bash
packer build bionic.json
```

## Build with Docker qemu based image

To build the image localy with the [Dockerfile](Dockerfile) :

```shell
docker build -t goffinet/packer-qemu .
```

`goffinet/packer-qemu` is a Docker image for building qemu images with packer


```bash
docker run --rm \
  -e PACKER_LOG=1 \
  -e PACKER_LOG_PATH="packer-docker.log" \
  -it \
  --privileged \
  --cap-add=ALL -v /lib/modules:/lib/modules \
  -v `pwd`:/opt/ \
  -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
  -e AWS_SECRET_KEY=$AWS_SECRET_KEY \
  -w /opt/ goffinet/packer-qemu build centos7.json
```

The script `build.sh` do it with the template name as first argument.

```bash
./build.sh centos7.json
```

## Packing monitoring

...

## Exploit with Libvirt

[https://github.com/goffinet/virt-scripts](https://github.com/goffinet/virt-scripts)

1. Clone virt-scripts repo and prepare the machine

  ```bash
  sudo apt update && apt -y install git
  git clone https://github.com/goffinet/virt-scripts
  cd virt-scripts
  sudo ./autoprep.sh
  ```

2. Build or download images

  Put builded images in `/var/lib/libvirt/images` or download them :

  ```bash
  sudo ./download-images.sh
  ```
  ```raw
  Please provide the image name :
  centos7 bionic debian10
  ```

3. Launch two new machines

  ```bash
  sudo ./define-guest-images.sh c1 centos7
  sudo ./define-guest-images.sh u1 bionic
  ```

4. Enjoy

  ```bash
  sudo virsh console u1
  ```

  ```bash
  ssh $(dig @192.168.122.1 +short u1)
  ```

## Exploit with Terraform and Libvirt Provider

```bash
echo "security_driver = \"none\"" >> /etc/libvirt/qemu.conf
systemctl restart libvirtd
sudo yum -y install wget unzip || sudo apt update && sudo apt -y install wget unzip
wget https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip
unzip terraform_0.13.2_linux_amd64.zip
chmod +x terraform
mv terraform /usr/local/bin/
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
tar xvf terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
mkdir -p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
cp -r terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64/
```

...

## ToDo

* Remove swap post-processing

## Credits

* [https://github.com/idi-ops/packer-kvm-centos](https://github.com/idi-ops/packer-kvm-centos)
* [https://github.com/jakobadam/packer-qemu-templates](https://github.com/jakobadam/packer-qemu-templates)
* [https://github.com/leonkyneur/packer-qemu](https://github.com/leonkyneur/packer-qemu)
* [https://github.com/kaorimatz/packer-templates](https://github.com/kaorimatz/packer-templates)
* [https://github.com/bramford/packer-debian9](https://github.com/bramford/packer-debian9)
* [https://github.com/bpetit/packer-templates](https://github.com/bpetit/packer-templates)
* [https://github.com/NeCTAR-RC/nectar-images/](https://github.com/NeCTAR-RC/nectar-images/)
