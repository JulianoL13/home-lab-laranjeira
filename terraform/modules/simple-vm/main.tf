locals {
  ip_with_cidr = "${var.ip_address}/${var.cidr}"
  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    user    = var.user
    ssh_key = var.ssh_key
  })
}

# Download cloud image (only if creating template)
resource "proxmox_virtual_environment_download_file" "cloud_image" {
  count = var.template_vmid == 0 ? 1 : 0

  content_type       = "iso"
  datastore_id       = var.storage
  node_name          = var.node_name
  url                = var.image_url
  file_name          = var.image_name
  checksum           = var.image_sha256 != "" ? var.image_sha256 : null
  checksum_algorithm = var.image_sha256 != "" ? "sha256" : null
  overwrite          = true
}

# Cloud-init config
resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = var.storage
  node_name    = var.node_name

  source_raw {
    data      = local.user_data
    file_name = "${var.name}-cloud-config.yaml"
  }
}

# VM Resource
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  vm_id     = var.vmid
  node_name = var.node_name
  template  = var.template_vmid == 0

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  agent {
    enabled = true
  }

  boot_order    = ["scsi0"]
  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    import_from  = var.template_vmid == 0 ? proxmox_virtual_environment_download_file.cloud_image[0].id : null
    size         = var.disk_size
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  # Clone from template if specified
  dynamic "clone" {
    for_each = var.template_vmid != 0 ? [1] : []
    content {
      vm_id = var.template_vmid
    }
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    ip_config {
      ipv4 {
        address = local.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      username = var.user
      keys     = [var.ssh_key]
    }
  }
}