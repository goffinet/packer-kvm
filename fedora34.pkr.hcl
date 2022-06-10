
variable "config_file" {
  type    = string
  default = "fedora34-kickstart.cfg"
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
  default = "e1a38b9faa62f793ad4561b308c31f32876cfaaee94457a7a9108aaddaeec406"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_urls" {
  type    = string
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-netinst-x86_64-34-1.2.iso"
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
  default = "34"
}

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "qemu" "{{user_`name`}}{{user_`version`}}" {
  accelerator          = "kvm"
  boot_command         = ["<tab> linux text net.ifnames=0 biosdevname=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/{{user `config_file`}}<enter><wait>"]
  boot_wait            = "40s"
  disk_cache           = "none"
  disk_compression     = true
  disk_discard         = "unmap"
  disk_interface       = "virtio"
  disk_size            = "{{user `disk_size`}}"
  format               = "qcow2"
  headless             = "{{user `headless`}}"
  http_directory       = "."
  iso_checksum         = "{{user `iso_checksum`}}"
  iso_urls             = "{{user `iso_urls`}}"
  net_device           = "virtio-net"
  output_directory     = "artifacts/qemu/{{user `name`}}{{user `version`}}"
  qemu_binary          = "/usr/bin/qemu-system-x86_64"
  qemuargs             = [["-m", "{{user `ram`}}M"], ["-smp", "{{user `cpu`}}"]]
  shutdown_command     = "sudo /usr/sbin/shutdown -h now"
  ssh_password         = "{{user `ssh_password`}}"
  ssh_private_key_file = "{{user `ssh_private_key_file`}}"
  ssh_username         = "{{user `ssh_username`}}"
  ssh_wait_timeout     = "30m"
}

build {
  sources = ["source.qemu.{{user_`name`}}{{user_`version`}}"]

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
