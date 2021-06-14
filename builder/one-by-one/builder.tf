terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  zone            = "fr-par-1"
  region          = "fr-par"
}

variable "AWS_ACCESS_KEY" {
  type = string
}

variable "AWS_SECRET_KEY" {
  type = string
}

locals {
  instance_type = "DEV1-L"
#  instance_type = "GP1-XS"
#  instance_type = "GP1-S"
#  instance_type = "GP1-M"
#  instance_type = "GP1-L"
#  instance_type = "GP1-XL"
#  instance_type = "DEV1-S"
#  instance_type = "DEV1-M"
#  instance_type = "DEV1-XL"
  tags = [ "builder" ]
  count = 1
}

resource "scaleway_instance_ip" "public_ip" {
count = local.count
}

resource "scaleway_instance_security_group" "builder" {
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"
  name = "builder-${terraform.workspace}"
}

resource "scaleway_instance_server" "builder" {
  count = local.count
  name  = "builder-${count.index}"
  type  = local.instance_type
  image = "ubuntu-bionic"
  tags = local.tags
  enable_ipv6 = false
  ip_id = scaleway_instance_ip.public_ip[count.index].id
  security_group_id = scaleway_instance_security_group.builder.id
#  provisioner "local-exec" {
#    command = "ansible-playbook -i '${self.public_ip},' playbook.yml -e \"provider=scaleway\" ; ansible-playbook ../../playbooks/deploy.yml -e \"ansible_host=${self.public_ip}\""
#  }

  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "apt update && apt -y install git",
      "git clone https://github.com/goffinet/packer-kvm",
      "cd packer-kvm",
      "echo export AWS_ACCESS_KEY=${var.AWS_ACCESS_KEY} >> ~/.profile",
      "echo export AWS_SECRET_KEY=${var.AWS_SECRET_KEY} >> ~/.profile",
      "source ~/.profile",
      "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh",
      "for x in *.json ; do docker run --rm -e PACKER_LOG=1 -e PACKER_LOG_PATH=$x.log -it --name $x --privileged --cap-add=ALL -v /lib/modules:/lib/modules -v $PWD:/opt/ -e AWS_ACCESS_KEY=${var.AWS_ACCESS_KEY} -e AWS_SECRET_KEY=${var.AWS_SECRET_KEY} -w /opt/ goffinet/packer-qemu build $x ; done",
      "while $(docker ps --format {{.Names}} | grep -q json) ; do echo waiting build ; sleep 60 ; done ; echo build finished ; true",
    ]
  }
}
