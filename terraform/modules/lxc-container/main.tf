module "workload_processor" {
  source = "../common"

  workload_configurations = var.container_configurations
  name_prefix             = var.name_prefix
  defaults = {
    memory    = var.default_memory
    cores     = var.default_cores
    disk_size = var.default_rootfs_size
    storage   = var.default_storage
    cidr      = var.default_cidr
  }
}

locals {
  processed_containers = {
    for name, container in module.workload_processor.processed_workloads :
    name => merge(container, {
      extra_config = try(container.extra_config, {})
    })
  }
}

# ===== DOWNLOAD DO TEMPLATE LXC =====
# Template baixado com configurações otimizadas para evitar conflicts
resource "proxmox_virtual_environment_download_file" "lxc_template" {
  count = var.ensure_template ? 1 : 0

  content_type        = "vztmpl"
  datastore_id        = var.template_storage
  node_name           = var.node_name
  url                 = var.template_url
  file_name           = var.template_name
  checksum            = "75a827c4ea4b2bef42e0521f51ed869e398f56b0e6b131c3cd5d284a2e0e08b5"
  checksum_algorithm  = "sha256"
  overwrite           = true
  overwrite_unmanaged = true # Permite sobrescrever arquivos criados fora do Terraform
  upload_timeout      = 1800 # 30 minutos - suficiente para downloads
  verify              = true

  # === DELAY PARA EVITAR CONFLITOS ===
  # Pequeno delay após download para estabilizar storage
  provisioner "local-exec" {
    command = "sleep 2"
  }
}

resource "proxmox_virtual_environment_container" "containers" {
  for_each = local.processed_containers

  # === DEPENDÊNCIAS EXPLÍCITAS PARA PREVENIR LOCKS ===
  # Força aguardar download do template antes de criar containers
  depends_on = [proxmox_virtual_environment_download_file.lxc_template]

  vm_id         = each.value.vmid
  node_name     = var.node_name
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = var.started

  # === TIMEOUTS OTIMIZADOS PARA PREVENIR LOCKS ===
  # Valores aumentados para evitar timeout durante operações concorrentes
  timeout_create = 1200 # 20 minutos - permite serialização automática
  timeout_update = 900  # 15 minutos para operações de update
  timeout_delete = 600  # 10 minutos para delete
  timeout_clone  = 1800 # 30 minutos para clonagem (maior timeout para evitar locks)

  protection  = try(each.value.extra_config.protection, false)
  description = try(each.value.extra_config.description, null)
  tags        = try(each.value.extra_config.tags, [])

  # === PREVENÇÃO DE CONFLITOS DE STORAGE ===
  # Lifecycle rule para reduzir conflitos durante atualizações
  lifecycle {
    create_before_destroy = false
    # Ignora mudanças em tags se necessário (Proxmox força lowercase)
    ignore_changes = []
  }

  operating_system {
    template_file_id = "${var.template_storage}:vztmpl/${var.template_name}"
    type             = var.os_type
  }

  # === FEATURES PARA CONTAINERS MODERNOS ===
  features {
    nesting = var.enable_nesting # Permite containers executarem Docker/LXD/outros containers
    fuse    = false              # FUSE filesystem (manter false se não necessário)
    keyctl  = false              # Sistema keyctl (manter false se não necessário)
  }

  cpu {
    cores = each.value.cores

    units = try(each.value.extra_config.cpu_units, null)
  }

  memory {
    dedicated = each.value.memory
    swap      = var.default_swap
  }

  disk {
    datastore_id = each.value.storage
    size         = each.value.disk_size
  }

  initialization {
    hostname = each.value.workload_name

    ip_config {
      ipv4 {
        address = each.value.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      password = var.password

      keys = try(each.value.extra_config.ssh_keys, null)
    }

    dns {
      servers = try(each.value.extra_config.dns_servers, null)
      domain  = try(each.value.extra_config.dns_domain, null)
    }
  }

  network_interface {
    name    = var.network_interface_name
    bridge  = var.bridge
    enabled = var.network_interface_enabled

    mac_address = try(each.value.extra_config.mac_address, null)
    mtu         = try(each.value.extra_config.network_mtu, null)
    rate_limit  = try(each.value.extra_config.network_rate_limit, null)
    vlan_id     = try(each.value.extra_config.vlan_id, null)
    firewall    = try(each.value.extra_config.network_firewall, false)
  }

  # === BLOCOS DINÂMICOS PARA RECURSOS EXTRAS ===

  dynamic "mount_point" {
    for_each = try(each.value.extra_config.additional_mount_points, [])
    content {
      volume = mount_point.value.volume
      size   = lookup(mount_point.value, "size", null)
      path   = mount_point.value.path
      backup = lookup(mount_point.value, "backup", false)
    }
  }

  dynamic "network_interface" {
    for_each = try(each.value.extra_config.additional_networks, [])
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
