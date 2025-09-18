module "workload_processor" {
  source = "../common"

  workload_configurations = var.vm_configurations
  name_prefix             = var.name_prefix
  defaults = {
    memory    = var.default_memory
    cores     = var.default_cores
    disk_size = var.default_disk_size
    storage   = var.default_storage
    cidr      = var.default_cidr
  }
}

locals {
  template_vmid = var.base_vmid
  processed_vms = {
    for name, vm in module.workload_processor.processed_workloads :
    name => merge(vm, {
      extra_config = try(vm.extra_config, {})
    })
  }

  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    user    = var.user
    ssh_key = var.ssh_key
  })
}

# Download da cloud image - configurado para sobrescrever se necessário
resource "proxmox_virtual_environment_download_file" "cloud_image" {
  count = var.create_template ? 1 : 0

  content_type        = "import" # Corrigido: 'import' para cloud images
  datastore_id        = var.default_snippet_storage
  node_name           = var.node_name
  url                 = var.image_url
  file_name           = var.image_name
  checksum            = var.image_sha256 != "" ? var.image_sha256 : null
  checksum_algorithm  = var.image_sha256 != "" ? "sha256" : null
  overwrite           = true
  overwrite_unmanaged = true # Permite sobrescrever arquivos criados fora do Terraform
  upload_timeout      = 3600 # Aumentado para 1 hora devido ao tamanho das cloud images
  verify              = true # Verifica certificados SSL
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  count = var.create_template ? 1 : 0

  content_type = "snippets"
  datastore_id = var.default_snippet_storage
  node_name    = var.node_name

  # Timeout padrão é suficiente para snippets pequenos
  overwrite = true

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
  started   = false # Template nunca deve ser iniciado

  # === CONFIGURAÇÕES OTIMIZADAS ===
  machine = "q35" # Máquina moderna recomendada (Q35 + ICH9, 2009)

  # === TIMEOUTS OTIMIZADOS ===
  timeout_create = 600 # 10 minutos é suficiente para criação do template

  cpu {
    cores   = var.default_cores
    type    = "x86-64-v2-AES" # CPU type recomendado com AES para melhor performance
    sockets = 1               # Configuração explícita
  }

  memory {
    dedicated = var.default_memory
  }

  agent {
    enabled = false # Desabilitado por padrão - habilitar apenas quando agent estiver instalado
    timeout = "15m" # Timeout padrão
  }

  # Para VMs sem agent funcionando, force stop ao invés de shutdown
  stop_on_destroy = true

  boot_order    = [var.disk_interface]
  scsi_hardware = var.scsi_hardware

  disk {
    datastore_id = var.default_storage
    interface    = var.disk_interface
    import_from  = proxmox_virtual_environment_download_file.cloud_image[0].id
    size         = var.default_disk_size
    cache        = "writethrough" # Cache otimizado para template
    ssd          = false          # Configuração explícita
    iothread     = false          # Não necessário para template
  }

  network_device {
    bridge = var.bridge
    model  = var.network_model
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X (recomendado para Linux moderno)
  }

  initialization {
    datastore_id      = var.default_initialization_storage
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[0].id

    user_account {
      username = var.user
      keys     = var.ssh_key != "" ? [var.ssh_key] : []
    }
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.processed_vms

  name      = each.value.workload_name
  vm_id     = each.value.vmid
  node_name = var.node_name
  template  = false
  on_boot   = var.on_boot
  started   = var.started

  # === CONFIGURAÇÕES DE TIMEOUT OTIMIZADAS PARA VMs ===
  # === TIMEOUTS OTIMIZADOS ===
  timeout_create      = 600  # 10 minutos para criação 
  timeout_clone       = 900  # 15 minutos para clonagem
  timeout_migrate     = 1200 # 20 minutos para migração
  timeout_reboot      = 300  # 5 minutos para reboot
  timeout_shutdown_vm = 300  # 5 minutos para shutdown
  timeout_start_vm    = 300  # 5 minutos para start

  # === DEPENDÊNCIAS EXPLÍCITAS PARA GARANTIR ORDEM ===
  depends_on = [
    proxmox_virtual_environment_vm.template,
    proxmox_virtual_environment_download_file.cloud_image,
    proxmox_virtual_environment_file.cloud_config
  ]

  protection      = try(each.value.extra_config.protection, false)
  bios            = try(each.value.extra_config.bios, "seabios")
  machine         = try(each.value.extra_config.machine, "q35") # Máquina moderna por padrão
  description     = try(each.value.extra_config.description, null)
  keyboard_layout = try(each.value.extra_config.keyboard_layout, null)
  tags            = try(each.value.extra_config.tags, [])

  clone {
    vm_id   = local.template_vmid
    retries = 3 # Retry em caso de timeout durante criação múltipla
  }

  cpu {
    cores   = each.value.cores
    type    = "x86-64-v2-AES" # CPU type recomendado pela documentação
    sockets = try(each.value.extra_config.cpu_sockets, 1)

    flags        = try(each.value.extra_config.cpu_flags, null)
    architecture = try(each.value.extra_config.cpu_architecture, null)
  }

  memory {
    dedicated = each.value.memory

    floating = try(each.value.extra_config.memory_floating, null)
    shared   = try(each.value.extra_config.memory_shared, null)
  }

  agent {
    enabled = false # Desabilitado por padrão - habilitar apenas quando agent estiver instalado
    timeout = "15m" # Timeout padrão
  }

  # Para VMs sem agent funcionando, force stop ao invés de shutdown
  stop_on_destroy = true

  boot_order    = [var.disk_interface]
  scsi_hardware = var.scsi_hardware

  disk {
    datastore_id = each.value.storage
    interface    = var.disk_interface
    size         = each.value.disk_size

    cache     = try(each.value.extra_config.disk_cache, "writethrough")
    ssd       = try(each.value.extra_config.disk_ssd, false)
    iothread  = try(each.value.extra_config.disk_iothread, false)
    discard   = try(each.value.extra_config.disk_discard, "ignore") # Corrigido: "ignore" ao invés de false
    backup    = try(each.value.extra_config.disk_backup, true)
    replicate = try(each.value.extra_config.disk_replicate, true)
  }

  network_device {
    bridge      = var.bridge
    model       = var.network_model
    mac_address = try(each.value.extra_config.mac_address, null)
    vlan_id     = try(each.value.extra_config.vlan_id, null)

    mtu        = try(each.value.extra_config.network_mtu, null)
    rate_limit = try(each.value.extra_config.network_rate_limit, null)
    firewall   = try(each.value.extra_config.network_firewall, false)
  }

  dynamic "disk" {
    for_each = try(each.value.extra_config.additional_disks, [])
    content {
      datastore_id = disk.value.datastore_id
      interface    = lookup(disk.value, "interface", "scsi1")
      size         = disk.value.size
      cache        = lookup(disk.value, "cache", "writethrough")
      ssd          = lookup(disk.value, "ssd", false)
      iothread     = lookup(disk.value, "iothread", false)
      discard      = lookup(disk.value, "discard", "ignore") # Corrigido: "ignore" ao invés de false
    }
  }

  dynamic "network_device" {
    for_each = try(each.value.extra_config.additional_networks, [])
    content {
      bridge      = network_device.value.bridge
      model       = lookup(network_device.value, "model", var.network_model)
      mac_address = lookup(network_device.value, "mac_address", null)
      vlan_id     = lookup(network_device.value, "vlan_id", null)
      mtu         = lookup(network_device.value, "mtu", null)
      firewall    = lookup(network_device.value, "firewall", false)
    }
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X (recomendado para Linux moderno)
  }

  initialization {
    datastore_id = var.default_initialization_storage

    ip_config {
      ipv4 {
        address = each.value.ip_with_cidr
        gateway = var.gateway
      }
    }

    user_account {
      username = var.user
      keys     = var.ssh_key != "" ? [var.ssh_key] : []
    }
  }
}
