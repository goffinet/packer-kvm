
variable "config_file" {
  type    = string
  default = "focal"
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
  default = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "http://releases.ubuntu.com/20.04/ubuntu-20.04.4-live-server-amd64.iso"
}

variable "name" {
  type    = string
  default = "focal"
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
  default = ""
}

source "qemu" "focal" {
  accelerator            = "kvm"
  boot_command           = ["<enter><enter><f6><esc><wait>", "<bs><bs><bs><bs>", "autoinstall net.ifnames=0 biosdevname=0 ip=dhcp ipv6.disable=1 ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file}/ ", "--- <enter>"]
  boot_wait              = "3s"
  disk_cache             = "none"
  disk_compression       = true
  disk_discard           = "ignore"
  disk_interface         = "virtio"
  disk_size              = var.disk_size
  format                 = "qcow2"
  headless               = var.headless
  host_port_max          = 2229
  host_port_min          = 2222
  http_directory         = "."
  http_port_max          = 10089
  http_port_min          = 10082
  iso_checksum           = var.iso_checksum
  iso_url                = var.iso_url
  net_device             = "virtio-net"
  output_directory       = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary            = "/usr/bin/qemu-system-x86_64"
  qemuargs               = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "45m"
}

build {
  sources = ["source.qemu.focal"]

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
