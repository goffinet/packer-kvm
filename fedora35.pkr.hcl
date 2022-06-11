
variable "config_file" {
  type    = string
  default = "fedora35-kickstart.cfg"
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
  default = "sha256:dd35f955dd5a7054213a0098c6ee737ff116aa3090fc6dbfe89d424b5c3552dd"
}

variable "iso_url" {
  type    = string
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/35/Server/x86_64/iso/Fedora-Server-netinst-x86_64-35-1.2.iso"
}

variable "name" {
  type    = string
  default = "fedora"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "testtest"
}

variable "ssh_private_key_file" {
  type    = string
  default = "./sshkeys/id_rsa"
}

variable "ssh_username" {
  type    = string
  default = "user"
}

variable "version" {
  type    = string
  default = "35"
}

source "qemu" "fedora35" {
  accelerator          = "kvm"
  boot_command         = ["<up><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file}<enter><wait>"]
  boot_wait            = "40s"
  disk_cache           = "none"
  disk_compression     = true
  disk_discard         = "unmap"
  disk_interface       = "virtio"
  disk_size            = var.disk_size
  format               = "qcow2"
  headless             = var.headless
  http_directory       = "."
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  net_device           = "virtio-net"
  output_directory     = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary          = "/usr/bin/qemu-system-x86_64"
  qemuargs             = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"], ["-cpu", "host"]]
  shutdown_command     = "sudo /usr/sbin/shutdown -h now"
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_file
  ssh_username         = var.ssh_username
  ssh_wait_timeout     = "30m"
}

build {
  sources = ["source.qemu.fedora35"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["dnf -y install ansible"]
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
