# Exemplo de uso dos módulos

# Criar um template Ubuntu
module "ubuntu_template" {
  source = "./modules/vm-qemu"

  name         = "ubuntu-2204-template"
  vmid         = 9000
  node_name    = "pve"
  cores        = 2
  memory       = 2048
  disk_size    = 20
  storage      = "local-lvm"
  bridge       = "vmbr0"
  ip_address   = "192.168.1.100"
  cidr         = 24
  gateway      = "192.168.1.1"
  user         = "ubuntu"
  ssh_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..."
  image_url    = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  image_name   = "ubuntu-22.04-cloudimg-amd64.img"
  image_sha256 = "de5e632e17b8965f2baf4ea6d2b824788e154d9a65df4fd419ec4019898e15cd"
}

# Criar VMs baseadas no template
resource "proxmox_virtual_environment_vm" "k8s_master" {
  name      = "k8s-master"
  vm_id     = 101
  node_name = "pve"

  clone {
    vm_id = module.ubuntu_template.vm_id
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.101/24"
        gateway = "192.168.1.1"
      }
    }
  }
}

# Criar container LXC
module "docker_container" {
  source = "./modules/lxc-container"

  hostname       = "docker-host"
  vmid           = 200
  target_node    = "pve"
  ostemplate     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password       = "password123"
  unprivileged   = true
  cores          = 2
  memory         = 2048
  swap           = 512
  rootfs_storage = "local-lvm"
  rootfs_size    = "10G"
  bridge         = "vmbr0"
  net_name       = "eth0"
  ip_address     = "192.168.1.200"
  cidr           = 24
  gateway        = "192.168.1.1"
  mounts         = []
}
