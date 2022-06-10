
variable "config_file" {
  type    = string
  default = "centos7-kickstart.cfg"
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
  default = "07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_urls" {
  type    = string
  default = "http://ftp.belnet.be/mirror/ftp.centos.org/7/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
}

variable "name" {
  type    = string
  default = "centos"
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
  default = "7"
}

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "qemu" "{{user_`name`}}{{user_`version`}}" {
  accelerator      = "kvm"
  boot_command     = ["<up><wait><tab><wait> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/{{user `config_file`}}<enter><wait>"]
  boot_wait        = "40s"
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = "{{user `disk_size`}}"
  format           = "qcow2"
  headless         = "{{user `headless`}}"
  http_directory   = "."
  iso_checksum     = "{{user `iso_checksum`}}"
  iso_urls         = "{{user `iso_urls`}}"
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/{{user `name`}}{{user `version`}}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "{{user `ram`}}M"], ["-smp", "{{user `cpu`}}"]]
  shutdown_command = "sudo /usr/sbin/shutdown -h now"
  ssh_password     = "{{user `ssh_password`}}"
  ssh_username     = "{{user `ssh_username`}}"
  ssh_wait_timeout = "30m"
}

build {
  sources = ["source.qemu.{{user_`name`}}{{user_`version`}}"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["yum -y install epel-release", "yum repolist", "yum -y install ansible"]
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
