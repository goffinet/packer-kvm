#Generated by packer-kvm/build-packer-templates.yaml at 2024-10-18T20:53:05Z

variable "config_file" {
  type    = string
  default = "fedora40-kickstart.cfg"
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
  default = "sha256:1b4f163c55aa9b35bb08f3d465534aa68899a4984b8ba8976b1e7b28297b61fe"
}

variable "iso_url" {
  type    = string
  default = "https://fedora.cu.be/linux/releases/40/Server/x86_64/iso/Fedora-Server-netinst-x86_64-40-1.14.iso"
}

variable "name" {
  type    = string
  default = "fedora40"
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
  default = "40"
}

source "qemu" "fedora40" {
  accelerator      = "kvm"
  boot_command     = ["<tab><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file}<enter><wait>"]
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
  ssh_wait_timeout = "30m"
  boot_wait        = "40s"
}

build {
  sources = ["source.qemu.fedora40"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["dnf -y install epel-release", "dnf repolist", "dnf -y install ansible"]
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