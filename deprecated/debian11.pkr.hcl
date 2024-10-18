
variable "config_file" {
  type    = string
  default = "debian-preseed.cfg"
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
  default = "sha256:7892981e1da216e79fb3a1536ce5ebab157afdd20048fe458f2ae34fbc26c19b"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso"
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
  default = "11"
}

source "qemu" "debian11" {
  accelerator      = "kvm"
  boot_command     = ["<esc><wait>", "auto <wait>", "console-keymaps-at/keymap=us <wait>", "console-setup/ask_detect=false <wait>", "debconf/frontend=noninteractive <wait>", "debian-installer=en_US <wait>", "fb=false <wait>", "install <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>", "locale=en_US <wait>", "netcfg/get_hostname=${var.name}${var.version} <wait>", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file} <wait>", "<enter><wait>"]
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
  iso_url          = var.iso_url
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  ssh_wait_timeout = "30m"
}

build {
  sources = ["source.qemu.debian11"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    inline          = ["echo \"deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main\" >> /etc/apt/sources.list", "apt -y install dirmngr", "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367", "apt-get update", "apt -y install ansible"]
  }

  provisioner "ansible-local" {
    playbook_dir  = "ansible"
    playbook_file = "ansible/playbook.yml"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    inline          = ["apt -y remove ansible", "apt-get clean", "apt-get -y autoremove --purge"]
  }

  post-processor "shell-local" {
    environment_vars = ["IMAGE_NAME=${var.name}", "IMAGE_VERSION=${var.version}", "DESTINATION_SERVER=${var.destination_server}"]
    script           = "scripts/push-image.sh"
  }
}
