# packer-kvm

Create VM templates with Packer for usage with Libvirt/KVM virtualization : centos 7, centos 8, bionic (ubuntu 1804), focal (ubuntu 2004), debian 10 (stable) and Fedora (32).

Only for education and learning purposes. Do not use it in production.

## Packer Concepts

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. ([Introduction to Packer, What is Packer?](https://www.packer.io/intro#what-is-packer))

Builders are responsible for creating machines and generating images from them for various platforms. For example, there are separate builders for EC2, VMware, VirtualBox, etc. Packer comes with many builders by default, and can also be extended to add new builders. ([Builders](https://www.packer.io/docs/builders))

Provisioners use builtin and third-party software to install and configure the machine image after booting. ([Provisioners](https://www.packer.io/docs/provisioners))

Post-processors run after the image is built by the builder and provisioned by the provisioner(s). ([Post-Processors](https://www.packer.io/docs/post-processors))

## Proof of Concept to generate Linux qemu images

This is a Packer "Proof of Concept" with :

* qemu/kvm as image _builder_ (qcow2)
* "shell" and "ansible-local" as _provisionners_
* "shell-local" as _post-processor_ to generate a [gns3a appliance file](https://docs.gns3.com/1MAdxz0BSEAfGM7tA-w-o3TMmf8XOx7nBf0z6d9nRz_c/index.html), checksum and upload to a server

Optionnal :

* run this inside a docker container
* build your own container

Enjoy those images with :

* Libvirt native tools
* Terraform as IaC tool with a third party Libvirtd Provider plugin

The built images are intended to be published on a S3 bucket.

## Pre-requisites

The run this project with success, you need a virtualization server and some softwares installed :

* Libvirt/KVM, Packer and aws s3 cli
* Docker (to run the build inside a container)

Use `./setup.sh` for a quick setup of Libvirt/KVM, Packer and `aws s3 cli` but please read before the following manual instructions.

For Docker usage, install it and put your aws S3 credits in your `~/.profile`.

Anyway, you can remove the post-processor in your image JSON template to avoid S3 upload attemps.

### AWS S3

Configure your S3 credits :

```bash
echo "export AWS_ACCESS_KEY=<your AWS_ACCESS_KEY>" >> ~/.profile
echo "export AWS_SECRET_KEY=<your AWS_SECRET_KEY>" >> ~/.profile
source ~/.profile
```

### Libvirt and Packer

Install Livirt/KVM on your server :

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

Install the Packer binary :

```bash
yum -y install wget unzip || apt update && apt -y install wget unzip
latest=$(curl -L -s https://releases.hashicorp.com/packer | grep 'packer_' | sed 's/^.*<.*\">packer_\(.*\)<\/a>/\1/' | head -1)
wget https://releases.hashicorp.com/packer/${latest}/packer_${latest}_linux_amd64.zip
unzip packer*.zip
chmod +x packer
mv packer /usr/local/bin/
```

### Docker

Get Docker et docker-compose :

```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y install python3-pip
elif [ -f /etc/redhat-release ]; then
yum -y install python3-pip
fi
pip3 install docker-compose
```

## Build with Packer

Each JSON file is a template for a distribution :

* [bionic.json](https://github.com/goffinet/packer-kvm/blob/master/bionic.json)
* [centos7.json](https://github.com/goffinet/packer-kvm/blob/master/centos7.json)
* [centos8.json](https://github.com/goffinet/packer-kvm/blob/master/centos8.json)
* [debian10.json](https://github.com/goffinet/packer-kvm/blob/master/debian10.json)
* [fedora32.json](https://github.com/goffinet/packer-kvm/blob/master/fedora32.json)
* [focal.json](https://github.com/goffinet/packer-kvm/blob/master/focal.json)

For example :

```bash
packer build centos7.json
```

## Build with Docker qemu based image

`goffinet/packer-qemu` is a Docker image for building qemu images with packer and is avaible on Docker Hub.


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

The script `build.sh` do it with the template filename as first argument.

```bash
./build.sh centos7.json
```

To build the image localy with the [Dockerfile](https://github.com/goffinet/packer-kvm/blob/master/Dockerfile) :

```shell
docker build -t packer-qemu .
```

## Packing monitoring

Packer use VNC to launch a temporary VM, you can check this window with a VNC client like `vinagre`.

You can have more details from Packet with the env var `PACKER_LOG=1`.

## Cloud images for qemu/KVM/Libvirt built with Packer

I build images for qemu/KVM with this project and publish them for use in these other IaC projects: [Virt-scripts](https://github.com/goffinet/virt-scripts) and **[Terraform with Libvirt/KVM provider](https://github.com/goffinet/terraform-libvirt)**.

- [bionic.qcow2 (Ubuntu 18.04)](http://get.goffinet.org/kvm/bionic.qcow2) [[md5sum]](http://get.goffinet.org/kvm/bionic.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/bionic.qcow2.sha256sum)
- [centos7.qcow2](http://get.goffinet.org/kvm/centos7.qcow2) [[md5sum]](http://get.goffinet.org/kvm/centos7.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/centos7.qcow2.sha256sum)
- [centos8.qcow2](http://get.goffinet.org/kvm/centos8.qcow2) [[md5sum]](http://get.goffinet.org/kvm/centos8.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/centos8.qcow2.sha256sum)
- [debian10.qcow2](http://get.goffinet.org/kvm/debian10.qcow2) [[md5sum]](http://get.goffinet.org/kvm/debian10.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/debian10.qcow2.sha256sum)
- [fedora32.qcow2](http://get.goffinet.org/kvm/fedora32.qcow2) [[md5sum]](http://get.goffinet.org/kvm/fedora32.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/fedora32.qcow2.sha256sum)
- [focal.qcow2 (Ubuntu 20.04)](http://get.goffinet.org/kvm/focal.qcow2) [[md5sum]](http://get.goffinet.org/kvm/focal.qcow2.md5sum) [[sha256sum]](http://get.goffinet.org/kvm/focal.qcow2.sha256sum)

You can easily download them to `/var/lib/libvirt/images` with this script :

```bash
curl -s -o /usr/local/bin/download-images.sh https://raw.githubusercontent.com/goffinet/virt-scripts/master/download-images.sh
chmod +x /usr/local/bin/download-images.sh
download-images.sh
```

## How to exploit those built images

How to exploit those built images?

- In the old way with Libvirt and some bash scripts
- In a beter way with a tool like Terraform

This is always beter to know how Libvirt is working. Can you read fundamentals about [KVM virtualization in french](https://linux.goffinet.org/administration/virtualisation-kvm/).

### Enjoy with Libvirt

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

### Enjoy with Terraform (with libvirt)

[https://github.com/goffinet/terraform-libvirt](https://github.com/goffinet/terraform-libvirt)

Install Terraform 0.13 with a third party Libvirt provider plugin :

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

Compose your libvirt infrastructure :

```bash
git clone https://github.com/goffinet/terraform-libvirt
cd terraform-libvirt/basics/ubuntu
terraform plan
cd ../count
terraform plan
```

## ToDo

* Remove swap post-processing
* docker-compose for automation
* add versions of post-processing and images meta-datas

## Customization

### To customize post-processing

The `scripts/push-image.sh` generate somme meta-data and push the generated image to a pre-defined S3 Bucket.

To customize this process, you can change the content as it :

```bash
#!/bin/bash

name=$IMAGE_NAME
version=$IMAGE_VERSION
image="${name}${version}"
echo "artifacts/qemu/${image} post-processing ..."
```

Anyway, you can remove the post-processor in your image JSON template to avoid this script call.

### Customize SSH keys

To generate the ssh keys for provisionning and put it in the `sshkeys/` folder :

```bash
ssh-keygen -q -t rsa -N '' -C 'packer-kvm-default-key' -f sshkeys/id_rsa
```

To get the default ssh private key :

```bash
curl https://raw.githubusercontent.com/goffinet/packer-kvm/master/sshkeys/id_rsa
```

To get the default ssh public key :

```bash
curl https://raw.githubusercontent.com/goffinet/packer-kvm/master/sshkeys/id_rsa.pub
```

## Initials credits

* [https://github.com/idi-ops/packer-kvm-centos](https://github.com/idi-ops/packer-kvm-centos)
* [https://github.com/jakobadam/packer-qemu-templates](https://github.com/jakobadam/packer-qemu-templates)
* [https://github.com/leonkyneur/packer-qemu](https://github.com/leonkyneur/packer-qemu)
* [https://github.com/kaorimatz/packer-templates](https://github.com/kaorimatz/packer-templates)
* [https://github.com/bramford/packer-debian9](https://github.com/bramford/packer-debian9)
* [https://github.com/bpetit/packer-templates](https://github.com/bpetit/packer-templates)
* [https://github.com/NeCTAR-RC/nectar-images/](https://github.com/NeCTAR-RC/nectar-images/)
