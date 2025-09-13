locals {
  ip_with_cidr = "${var.ip_address}/${var.cidr}"
}

resource "proxmox_lxc" "container" {
  hostname     = var.hostname
  vmid         = var.vmid
  target_node  = var.target_node
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = var.unprivileged

  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = var.net_name
    bridge = var.bridge
    ip     = local.ip_with_cidr
    gw     = var.gateway
  }

  dynamic "mountpoint" {
    for_each = var.mounts
    content {
      slot    = mountpoint.value.slot
      storage = mountpoint.value.storage
      mp      = mountpoint.value.mp
      size    = mountpoint.value.size
      volume  = try(mountpoint.value.volume, null)
    }
  }
}

