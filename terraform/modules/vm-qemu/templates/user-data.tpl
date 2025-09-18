#cloud-config
# Cloud-init configuration template for VM user data
# This template is used to configure VMs during first boot

users:
  - name: ${user}
    groups: [adm, sudo]
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}

# Basic packages to install
packages:
  - curl
  - wget
  - htop
  - git
  - vim
  - unzip

# Enable password authentication over SSH (optional)
ssh_pwauth: true

# Run commands on first boot
runcmd:
  - echo 'Cloud-init configuration completed' > /var/log/cloud-init-custom.log
  - systemctl enable ssh
  - systemctl start ssh

# Set timezone
timezone: America/Sao_Paulo

# Configure automatic security updates
package_update: true
package_upgrade: true