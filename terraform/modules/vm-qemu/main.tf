locals {
  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    user    = var.user
    ssh_key = var.ssh_key
  })
  ip_with_cidr = "${var.ip_address}/${var.cidr}"
}

resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type       = "import"
  datastore_id       = var.storage
  node_name          = var.node_name
  url                = var.image_url
  file_name          = var.image_name
  checksum           = var.image_sha256
  checksum_algorithm = "sha256"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = var.storage
  node_name    = var.node_name

  source_raw {
    data      = local.user_data
    file_name = "${var.name}-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  name      = var.name
  vm_id     = var.vmid
  node_name = var.node_name
  template  = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    import_from  = proxmox_virtual_environment_download_file.cloud_image.id
    size         = var.disk_size
  }

  network_device {
    bridge = var.bridge
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    ip_config {
      ipv4 {
        address = local.ip_with_cidr
        gateway = var.gateway
      }
    }
  }
}
