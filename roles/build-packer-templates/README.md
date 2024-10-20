# Ansible Role: Build Packer Templates

This Ansible role automates the creation of Packer templates for building virtual machine images. It supports both Debian-based and Red Hat-based systems, generating the necessary configuration files and templates for automated image creation.

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
    images:
      - type: "redhat"
        flavor: "almalinux"
        version: "9.4"
      - type: "debian"
        flavor: "ubuntu"
        version: "20.04"
  roles:
    - role: build-packer-templates
```

## License

This project is licensed under the MIT License.

## Author Information

This role was created by [Your Name].
