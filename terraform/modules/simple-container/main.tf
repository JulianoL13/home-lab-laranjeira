locals {
  ip_with_cidr = "${var.ip_address}/${var.cidr}"
}

resource "proxmox_virtual_environment_container" "container" {
  vm_id        = var.vmid
  node_name    = var.node_name
  unprivileged = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.storage
    size         = var.rootfs_size
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    enabled = true
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "ubuntu"
  }

  initialization {
    hostname = var.name

    ip_config {
      ipv4 {
        address = local.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      password = var.password
    }
  }
}