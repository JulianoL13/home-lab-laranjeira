locals {
  ip_with_cidr = "${var.ip_address}/${var.cidr}"
}

resource "proxmox_virtual_environment_container" "container" {
  description  = var.description
  node_name    = var.target_node
  vm_id        = var.vmid
  unprivileged = var.unprivileged

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.rootfs_storage
    size         = var.rootfs_size
  }

  network_interface {
    name    = var.net_name
    bridge  = var.bridge
    enabled = true

    ip_config {
      ipv4 {
        address = local.ip_with_cidr
        gateway = var.gateway
      }
    }
  }

  operating_system {
    template_file_id = var.ostemplate
    type             = "ubuntu"
  }

  initialization {
    hostname = var.hostname

    user_account {
      password = var.password
    }
  }

  dynamic "mount_point" {
    for_each = var.mounts
    content {
      volume = mount_point.value.volume
      path   = mount_point.value.mp
      size   = mount_point.value.size
    }
  }
}

