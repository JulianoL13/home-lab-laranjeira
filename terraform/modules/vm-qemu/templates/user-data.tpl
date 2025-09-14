#cloud-config
users:
  - name: ${user}
    ssh_authorized_keys:
      - ${ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: [adm, cdrom, dip, plugdev, lxd, sudo]

packages:
  - qemu-guest-agent
  - curl
  - wget
  - htop
  - vim
  - git

package_update: true
package_upgrade: true

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable ssh
  - systemctl start ssh

ssh_pwauth: false
disable_root: true

# Configurações de timezone
timezone: America/Sao_Paulo

# Configurações de locale
locale: pt_BR.UTF-8
