#Generated by packer-kvm/build-packer-templates.yaml at 2024-10-19T13:24:50Z

variable "config_file" {
  type    = string
  default = "user-data"
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
  default = "file:http://releases.ubuntu.com/22.04/SHA256SUMS"
}

variable "iso_url" {
  type    = string
  default = "http://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "name" {
  type    = string
  default = "ubuntu"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
  }

variable "ssh_username" {
  type    = string
  default = "ubuntu"
  }

variable "version" {
  type    = string
  default = "2204"
}

source "qemu" "ubuntu2204" {
  accelerator      = "kvm"
  boot_command     = ["c<wait>linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.name}${var.version}/"<enter><wait>", "initrd /casper/initrd<enter><wait>", "boot<enter><wait>"]
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
  boot_wait              = "3s"
  ssh_handshake_attempts = 500
  ssh_timeout            = "45m"
  ssh_wait_timeout       = "45m"
  host_port_max          = 2229
  host_port_min          = 2222
  http_port_max          = 10089
  http_port_min          = 10082
}

build {
  sources = ["source.qemu.ubuntu2204"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["sudo apt-get update", "sudo apt-get -y install software-properties-common", "sudo apt-add-repository --yes --update ppa:ansible/ansible", "sudo apt update", "sudo apt -y install ansible"]
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