
variable "config_file" {
  type    = string
  default = "ubuntu1804-preseed.cfg"
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
  default = "sha256:bed8a55ae2a657f8349fe3271097cff3a5b8c3d1048cf258568f1601976fa30d"
}

variable "iso_url" {
  type    = string
  default = "http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/mini.iso"
}

variable "name" {
  type    = string
  default = "bionic"
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
  default = ""
}

source "qemu" "bionic" {
  accelerator      = "kvm"
  boot_command     = ["<tab><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "net.ifnames=0 biosdevname=0 fb=false hostname=${var.name}${var.version} locale=en_US ", "console-keymaps-at/keymap=us console-setup/ask_detect=false ", "console-setup/layoutcode=us keyboard-configuration/layout=USA keyboard-configuration/variant=USA ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file} <enter><wait>"]
  boot_wait        = "15s"
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = var.disk_size
  format           = "qcow2"
  headless         = var.headless
  host_port_max    = 2229
  host_port_min    = 2222
  http_directory   = "."
  http_port_max    = 10089
  http_port_min    = 10082
  iso_checksum     = var.iso_checksum
  iso_url         = var.iso_url
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  ssh_wait_timeout = "45m"
}

build {
  sources = ["source.qemu.bionic"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["sudo apt-get update", "sudo apt-get -y install software-properties-common", "sudo apt-add-repository --yes --update ppa:ansible/ansible", "sudo apt update", "sudo apt -y install ansible"]
  }

  provisioner "ansible-local" {
    playbook_dir  = "ansible"
    playbook_file = "ansible/playbook.yml"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["sudo apt -y remove ansible", "sudo apt-get clean", "sudo apt-get -y autoremove --purge"]
  }

  post-processor "shell-local" {
    environment_vars = ["IMAGE_NAME=${var.name}", "IMAGE_VERSION=${var.version}", "DESTINATION_SERVER=${var.destination_server}"]
    script           = "scripts/push-image.sh"
  }
}
