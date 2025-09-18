# ===== OUTPUTS ÚTEIS =====

# ===== VM OUTPUTS =====
output "vm_ips" {
  description = "IPs das VMs criadas para conexão rápida"
  value = {
    for name, config in local.vm_configs :
    name => config.ip_address
  }
}

output "vm_ssh_commands" {
  description = "Comandos SSH prontos para conexão às VMs"
  value = {
    for name, config in local.vm_configs :
    name => "ssh ${var.vm_user}@${config.ip_address}"
  }
}

output "vm_details" {
  description = "Detalhes completos das VMs criadas"
  value = {
    for name, config in local.vm_configs :
    name => {
      vmid       = config.vmid
      ip_address = config.ip_address
      memory     = config.memory
      cores      = config.cores
      disk_size  = config.disk_size
      ssh_command = "ssh ${var.vm_user}@${config.ip_address}"
    }
  }
}

# ===== CONTAINER OUTPUTS =====
output "container_ips" {
  description = "IPs dos containers criados"
  value = {
    for name, config in local.container_configs :
    name => config.ip_address
  }
}

output "container_ssh_commands" {
  description = "Comandos SSH para conexão aos containers"
  value = {
    for name, config in local.container_configs :
    name => "ssh root@${config.ip_address}"
  }
}

output "container_details" {
  description = "Detalhes completos dos containers criados"
  value = {
    for name, config in local.container_configs :
    name => {
      vmid        = config.vmid
      ip_address  = config.ip_address
      memory      = config.memory
      cores       = config.cores
      rootfs_size = config.rootfs_size
      ssh_command = "ssh root@${config.ip_address}"
    }
  }
}

# ===== TEMPLATE OUTPUTS =====
output "template_vmid" {
  description = "VMID do template de VM criado"
  value       = 9000
}

# ===== SUMMARY OUTPUT =====
output "infrastructure_summary" {
  description = "Resumo completo da infraestrutura criada"
  value = {
    vms = {
      count   = length(local.vm_configs)
      details = local.vm_configs
    }
    containers = {
      count   = length(local.container_configs)
      details = local.container_configs
    }
    template = {
      vmid = 9000
      name = "${var.name_prefix}-template"
    }
  }
}