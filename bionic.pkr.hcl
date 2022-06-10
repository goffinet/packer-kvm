
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
  default = "bed8a55ae2a657f8349fe3271097cff3a5b8c3d1048cf258568f1601976fa30d"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_urls" {
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

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "qemu" "{{user_`name`}}{{user_`version`}}" {
  accelerator      = "kvm"
  boot_command     = ["<tab><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "net.ifnames=0 biosdevname=0 fb=false hostname={{user `name`}}{{user `version`}} locale=en_US ", "console-keymaps-at/keymap=us console-setup/ask_detect=false ", "console-setup/layoutcode=us keyboard-configuration/layout=USA keyboard-configuration/variant=USA ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/{{user `config_file`}} <enter><wait>"]
  boot_wait        = "15s"
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = "{{user `disk_size`}}"
  format           = "qcow2"
  headless         = "{{user `headless`}}"
  host_port_max    = 2229
  host_port_min    = 2222
  http_directory   = "."
  http_port_max    = 10089
  http_port_min    = 10082
  iso_checksum     = "{{user `iso_checksum`}}"
  iso_urls         = "{{user `iso_urls`}}"
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/{{user `name`}}{{user `version`}}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "{{user `ram`}}M"], ["-smp", "{{user `cpu`}}"]]
  shutdown_command = "echo '{{user `ssh_password`}}' | sudo -S shutdown -P now"
  ssh_password     = "{{user `ssh_password`}}"
  ssh_username     = "{{user `ssh_username`}}"
  ssh_wait_timeout = "45m"
}

build {
  sources = ["source.qemu.{{user_`name`}}{{user_`version`}}"]

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
