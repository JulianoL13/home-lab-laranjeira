locals {
  template_vmid = var.base_vmid

  processed_vms = {
    for name, config in var.vm_configurations :
    name => merge({
      memory                 = var.default_memory
      cores                  = var.default_cores
      disk_size              = var.default_disk_size
      storage                = var.default_storage
      snippet_storage        = var.default_snippet_storage
      initialization_storage = var.default_initialization_storage
      cidr                   = var.default_cidr
      }, config, {
      ip_with_cidr = "${config.ip_address}/${coalesce(lookup(config, "cidr", null), var.default_cidr)}"
      vm_name      = "${var.name_prefix}-${name}"

      # Processa o bloco de configurações extras
      extra_config = lookup(config, "extra_config", {})
    })
  }

  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    user    = var.user
    ssh_key = var.ssh_key
  })
}

resource "proxmox_virtual_environment_download_file" "cloud_image" {
  count = var.create_template ? 1 : 0

  content_type       = "iso"
  datastore_id       = var.default_snippet_storage
  node_name          = var.node_name
  url                = var.image_url
  file_name          = var.image_name
  checksum           = var.image_sha256 != "" ? var.image_sha256 : null
  checksum_algorithm = var.image_sha256 != "" ? "sha256" : null
  overwrite          = true
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  count = var.create_template ? 1 : 0

  content_type = "snippets"
  datastore_id = var.default_snippet_storage
  node_name    = var.node_name

  source_raw {
    data      = local.user_data
    file_name = "${var.name_prefix}-template-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  count = var.create_template ? 1 : 0

  name      = "${var.name_prefix}-template"
  vm_id     = local.template_vmid
  node_name = var.node_name
  template  = true
  on_boot   = false

  cpu {
    cores = var.default_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.default_memory
  }

  agent {
    enabled = var.agent_enabled
  }

  boot_order    = [var.disk_interface]
  scsi_hardware = var.scsi_hardware

  disk {
    datastore_id = var.default_storage
    interface    = var.disk_interface
    file_id      = proxmox_virtual_environment_download_file.cloud_image[0].id
    size         = var.default_disk_size
  }

  network_device {
    bridge = var.bridge
    model  = var.network_model
  }

  initialization {
    datastore_id      = var.default_initialization_storage
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[0].id

    user_account {
      username = var.user
      keys     = [var.ssh_key]
    }
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.processed_vms

  name      = each.value.vm_name
  vm_id     = each.value.vmid
  node_name = var.node_name
  template  = false
  on_boot   = var.on_boot
  started   = var.started

  # Garante que o template seja criado antes das VMs
  depends_on = [proxmox_virtual_environment_vm.template]

  # === CONFIGURAÇÕES EXTRAS DO BLOCO extra_config ===
  protection      = lookup(each.value.extra_config, "protection", false)
  bios            = lookup(each.value.extra_config, "bios", "seabios")
  machine         = lookup(each.value.extra_config, "machine", "pc")
  description     = lookup(each.value.extra_config, "description", null)
  keyboard_layout = lookup(each.value.extra_config, "keyboard_layout", null)
  tags            = lookup(each.value.extra_config, "tags", [])

  clone {
    vm_id = local.template_vmid # Sempre usar o valor estático para evitar dependências circulares
  }

  cpu {
    cores   = each.value.cores
    type    = var.cpu_type
    sockets = lookup(each.value.extra_config, "cpu_sockets", 1)

    # Propriedades extras de CPU do bloco
    flags        = lookup(each.value.extra_config, "cpu_flags", null)
    architecture = lookup(each.value.extra_config, "cpu_architecture", null)
  }

  memory {
    dedicated = each.value.memory

    # Propriedades extras de memória do bloco
    floating = lookup(each.value.extra_config, "memory_floating", null)
    shared   = lookup(each.value.extra_config, "memory_shared", null)
  }

  agent {
    enabled = var.agent_enabled
  }

  boot_order    = [var.disk_interface]
  scsi_hardware = var.scsi_hardware

  disk {
    datastore_id = each.value.storage
    interface    = var.disk_interface
    size         = each.value.disk_size

    # Propriedades extras de disco do bloco
    cache     = lookup(each.value.extra_config, "disk_cache", "writethrough")
    ssd       = lookup(each.value.extra_config, "disk_ssd", false)
    iothread  = lookup(each.value.extra_config, "disk_iothread", false)
    discard   = lookup(each.value.extra_config, "disk_discard", false)
    backup    = lookup(each.value.extra_config, "disk_backup", true)
    replicate = lookup(each.value.extra_config, "disk_replicate", true)
  }

  network_device {
    bridge      = var.bridge
    model       = var.network_model
    mac_address = lookup(each.value.extra_config, "mac_address", null)
    vlan_id     = lookup(each.value.extra_config, "vlan_id", null)

    # Propriedades extras de rede do bloco
    mtu        = lookup(each.value.extra_config, "network_mtu", null)
    rate_limit = lookup(each.value.extra_config, "network_rate_limit", null)
    firewall   = lookup(each.value.extra_config, "network_firewall", false)
  }

  # === BLOCOS DINÂMICOS PARA RECURSOS EXTRAS ===

  # Discos adicionais
  dynamic "disk" {
    for_each = lookup(each.value.extra_config, "additional_disks", [])
    content {
      datastore_id = disk.value.datastore_id
      interface    = lookup(disk.value, "interface", "scsi1")
      size         = disk.value.size
      cache        = lookup(disk.value, "cache", "writethrough")
      ssd          = lookup(disk.value, "ssd", false)
      iothread     = lookup(disk.value, "iothread", false)
      discard      = lookup(disk.value, "discard", false)
    }
  }

  dynamic "network_device" {
    for_each = lookup(each.value.extra_config, "additional_networks", [])
    content {
      bridge      = network_device.value.bridge
      model       = lookup(network_device.value, "model", var.network_model)
      mac_address = lookup(network_device.value, "mac_address", null)
      vlan_id     = lookup(network_device.value, "vlan_id", null)
      mtu         = lookup(network_device.value, "mtu", null)
      firewall    = lookup(network_device.value, "firewall", false)
    }
  }

  initialization {
    datastore_id = each.value.initialization_storage

    ip_config {
      ipv4 {
        address = each.value.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      username = var.user
      keys     = [var.ssh_key]
    }
  }
}
