#Generated by packer-kvm/build-packer-templates.yaml

packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "config_file" {
  type    = string
  default = "debian12-preseed.cfg"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "destination_server" {
  type    = string
  default = "download.goffinet.org"
}

variable "disk_size" {
  type    = string
  default = "40000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
}

variable "name" {
  type    = string
  default = "debian"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "testtest"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "version" {
  type    = string
  default = "12"
}

source "qemu" "debian12" {
  accelerator      = "kvm"
  boot_command     = ["<esc><wait>", "auto <wait>", "console-keymaps-at/keymap=us <wait>", "console-setup/ask_detect=false <wait>", "debconf/frontend=noninteractive <wait>", "debian-installer=en_US <wait>", "fb=false <wait>", "install <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>", "locale=en_US <wait>", "netcfg/get_hostname=${var.name}${var.version} <wait>", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file} <wait>", "<enter><wait>"]
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = var.disk_size
  format           = "qcow2"
  headless         = var.headless
  http_directory   = "."
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"], ["-cpu", "host"]]
  shutdown_command = "sudo /usr/sbin/shutdown -h now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  boot_wait              = "10s"
  ssh_handshake_attempts = 500
  ssh_timeout            = "45m"
  ssh_wait_timeout       = "45m"
  host_port_max          = 2229
  host_port_min          = 2222
  http_port_max          = 10089
  http_port_min          = 10082
}

build {
  sources = ["source.qemu.debian12"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          =  ["apt-get update", "apt -y install ansible"]
  }

  provisioner "ansible-local" {
    playbook_dir  = "ansible"
    playbook_file = "ansible/playbook.yml"
  }

  post-processor "shell-local" {
    environment_vars = ["IMAGE_NAME=${var.name}", "IMAGE_VERSION=${var.version}", "DESTINATION_SERVER=${var.destination_server}"]
    script           = "scripts/push-image.sh"
  }
}