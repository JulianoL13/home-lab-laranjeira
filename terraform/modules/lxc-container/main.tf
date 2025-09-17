locals {
  processed_containers = {
    for name, config in var.container_configurations :
    name => merge({
      memory      = var.default_memory
      cores       = var.default_cores
      rootfs_size = var.default_rootfs_size
      storage     = var.default_storage
      swap        = var.default_swap
      cidr        = var.default_cidr
      }, config, {

      storage        = coalesce(lookup(config, "storage", null), var.default_storage)
      ip_with_cidr   = "${config.ip_address}/${coalesce(lookup(config, "cidr", null), var.default_cidr)}"
      container_name = "${var.name_prefix}-${name}"

      # Processa o bloco de configurações extras
      extra_config = lookup(config, "extra_config", {})
    })
  }
}

resource "proxmox_virtual_environment_download_file" "lxc_template" {
  count = var.ensure_template ? 1 : 0

  content_type = "vztmpl"
  datastore_id = var.template_storage
  node_name    = var.node_name
  url          = var.template_url
  file_name    = var.template_name
  overwrite    = true
}

resource "proxmox_virtual_environment_container" "containers" {
  for_each = local.processed_containers

  vm_id         = each.value.vmid
  node_name     = var.node_name
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = var.started

  # === CONFIGURAÇÕES EXTRAS DO BLOCO extra_config ===
  protection  = lookup(each.value.extra_config, "protection", false)
  description = lookup(each.value.extra_config, "description", null)
  tags        = lookup(each.value.extra_config, "tags", [])

  operating_system {
    template_file_id = "${var.template_storage}:vztmpl/${var.template_name}"
    type             = var.os_type
  }

  cpu {
    cores = each.value.cores

    # Propriedades extras de CPU do bloco
    units = lookup(each.value.extra_config, "cpu_units", null)
  }

  memory {
    dedicated = each.value.memory
    swap      = each.value.swap
  }

  disk {
    datastore_id = each.value.storage
    size         = each.value.rootfs_size

  }

  initialization {
    hostname = each.value.container_name

    ip_config {
      ipv4 {
        address = each.value.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      password = var.password

      # Propriedades extras de usuário do bloco
      keys = lookup(each.value.extra_config, "ssh_keys", null)
    }

    # DNS personalizado
    dns {
      servers = lookup(each.value.extra_config, "dns_servers", null)
      domain  = lookup(each.value.extra_config, "dns_domain", null)
    }
  }

  network_interface {
    name    = var.network_interface_name
    bridge  = var.bridge
    enabled = var.network_interface_enabled

    # Propriedades extras de rede do bloco
    mac_address = lookup(each.value.extra_config, "mac_address", null)
    mtu         = lookup(each.value.extra_config, "network_mtu", null)
    rate_limit  = lookup(each.value.extra_config, "network_rate_limit", null)
    vlan_id     = lookup(each.value.extra_config, "vlan_id", null)
    firewall    = lookup(each.value.extra_config, "network_firewall", false)
  }

  # === BLOCOS DINÂMICOS PARA RECURSOS EXTRAS ===

  # Discos adicionais (mount points)
  dynamic "mount_point" {
    for_each = lookup(each.value.extra_config, "additional_mount_points", [])
    content {
      volume = mount_point.value.volume
      size   = lookup(mount_point.value, "size", null)
      path   = mount_point.value.path
      backup = lookup(mount_point.value, "backup", false)
    }
  }

  # Interfaces de rede adicionais
  dynamic "network_interface" {
    for_each = lookup(each.value.extra_config, "additional_networks", [])
    content {
      name        = network_interface.value.name
      bridge      = network_interface.value.bridge
      enabled     = lookup(network_interface.value, "enabled", true)
      mac_address = lookup(network_interface.value, "mac_address", null)
      mtu         = lookup(network_interface.value, "mtu", null)
      vlan_id     = lookup(network_interface.value, "vlan_id", null)
      firewall    = lookup(network_interface.value, "firewall", false)
    }
  }
}
