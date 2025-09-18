# ===== COMMON WORKLOAD PROCESSOR MODULE =====
# Este módulo processa configurações de workloads (VMs ou containers)
# aplicando valores padrão e gerando nomes consistentes

locals {
  # Processa cada workload aplicando valores padrão e gerando nomes
  processed_workloads = {
    for name, config in var.workload_configurations :
    name => {
      workload_name = "${var.name_prefix}-${name}"
      vmid          = config.vmid
      ip_address    = config.ip_address
      memory        = coalesce(config.memory, var.defaults.memory)
      cores         = coalesce(config.cores, var.defaults.cores)
      disk_size     = coalesce(config.disk_size, var.defaults.disk_size)
      storage       = coalesce(config.storage, var.defaults.storage)
      cidr          = coalesce(config.cidr, var.defaults.cidr)
      
      # Campos opcionais específicos para VMs
      snippet_storage        = try(config.snippet_storage, null)
      initialization_storage = try(config.initialization_storage, null)
      
      # Campos opcionais específicos para containers
      rootfs_size = try(config.rootfs_size, config.disk_size, var.defaults.disk_size)
      swap        = try(config.swap, null)
      
      # Configurações extras que podem ser passadas
      extra_config = try(config.extra_config, {})
    }
  }
}