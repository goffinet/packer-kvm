# Ansible Role: Build Packer Templates

## Overview

This Ansible role automates the creation of Packer templates for building virtual machine images. It supports both Debian-based and Red Hat-based systems, generating the necessary configuration files and templates for automated image creation. The role simplifies the process of creating consistent and reproducible images for various environments.

## Variables

The following variables are used in the Packer templates:

- **type**: Specifies the type of the operating system, such as "debian" or "redhat".

- **flavor**: Indicates the specific distribution flavor, like "ubuntu", "centos", or "fedora".
  
- **version**: The version of the operating system to be installed.

- **iso_url**: The URL from which the ISO image can be downloaded. This is essential for the installation process as it points to the installation media.
  
- **iso_name**: The name of the ISO file that will be downloaded. This is used to reference the specific image file in the build process.

- **checksum_filename**: The name of the file that contains the checksum for the ISO image. This is used to verify the integrity of the downloaded ISO file to ensure it has not been corrupted or tampered with.

## Role Structure

- **vars/main.yaml**: Intended for defining default variables used throughout the role. Currently empty.

- **tasks/debian.yaml**: Contains tasks specific to Debian-based systems, including setting computed variables, creating cloud-init configuration files, and generating Packer template files.

- **tasks/redhat.yaml**: Contains tasks specific to Red Hat-based systems, including setting computed variables, creating kickstart configuration files, and generating Packer template files.

- **tasks/main.yaml**: The main task file that includes other task files based on the type of image being built. It loops over a list of images and includes the appropriate task file.

- **templates/kickstart.cfg.j2**: A Jinja2 template for generating kickstart files used by Red Hat-based systems for automated installations.

- **templates/linux.pkr.hcl.j2**: A Jinja2 template for generating Packer configuration files. It defines variables and the build process for creating VM images.

- **templates/user-data.j2**: A Jinja2 template for generating cloud-init user-data files used by Ubuntu for automated installations.

- **defaults/main.yaml**: Contains default values for various parameters like destination server, VM specifications (CPU, RAM, disk size), boot commands, SSH credentials, and additional parameters for Packer builds.

## Default Values

The following default values are defined in `defaults/main.yaml`:

- **destination_server**: `"download.goffinet.org"`
- **vm**:
  - **cpu**: `"2"`
  - **disk_size**: `"40000"`
  - **ram**: `"2048"`
- **boot_command**: Varies based on the type and flavor of the system.
- **ssh_password**: `"testtest"` for Red Hat, `"ubuntu"` for Debian.
- **ssh_username**: `"root"` for Red Hat, `"ubuntu"` for Debian.
- **additional_parameters**: Includes SSH and boot wait time settings.
- **shell_provisioner**: Commands for installing Ansible on the system.

## Usage

To use this role, include it in your Ansible playbook and provide the necessary variables. The role will generate the required Packer templates and configuration files based on the input variables and system types.

## Example Playbook

```yaml
- hosts: localhost
  gather_facts: no
  vars:
    destination_server: download.goffinet.org
    images:
      - type: "redhat"
        flavor: "almalinux"
        version: "9.4"
        iso_url: "https://repo.almalinux.org/almalinux/9.4/isos/x86_64"
        iso_name: "AlmaLinux-9.4-x86_64-boot.iso"
        checksum_filename: "CHECKSUM"
      - type: "redhat"
        flavor: "centos"
        version: "9"
        iso_url: "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso"
        iso_name: "CentOS-Stream-9-20241016.0-x86_64-boot.iso"
        checksum_filename: "SHA256SUM"
      - type: "redhat"
        flavor: "fedora"
        version: "40"
        iso_url: "https://fedora.cu.be/linux/releases/40/Server/x86_64/iso"
        iso_name: "Fedora-Server-netinst-x86_64-40-1.14.iso"
        checksum_filename: "Fedora-Server-40-1.14-x86_64-CHECKSUM"
      - type: "debian"
        flavor: "ubuntu"
        version: "20.04"
        iso_url: "http://releases.ubuntu.com/20.04"
        iso_name: "ubuntu-20.04.6-live-server-amd64.iso"
        checksum_filename: "SHA256SUMS"
      - type: "debian"
        flavor: "ubuntu"
        version: "22.04"
        iso_url: "http://releases.ubuntu.com/22.04"
        iso_name: "ubuntu-22.04.5-live-server-amd64.iso"
        checksum_filename: "SHA256SUMS"
      - type: "debian"
        flavor: "ubuntu"
        version: "24.04"
        iso_url: "http://releases.ubuntu.com/24.04"
        iso_name: "ubuntu-24.04.1-live-server-amd64.iso"
        checksum_filename: "SHA256SUMS"
  roles:
    - name: Create packer-templates
      role: build-packer-templates
```
