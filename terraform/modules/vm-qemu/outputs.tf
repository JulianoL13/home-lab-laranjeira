output "template_id" {
  description = "VM ID do template criado"
  value       = var.create_template ? proxmox_virtual_environment_vm.template[0].vm_id : null
}

output "template_name" {
  description = "Nome do template criado"
  value       = var.create_template ? proxmox_virtual_environment_vm.template[0].name : null
}

output "vms" {
  description = "Informações das VMs criadas"
  value = {
    for name, vm in proxmox_virtual_environment_vm.vms : name => {
      vm_id      = vm.vm_id
      name       = vm.name
      ip_address = local.processed_vms[name].ip_address
      memory     = vm.memory[0].dedicated
      cores      = vm.cpu[0].cores
    }
  }
}

output "vm_ids" {
  description = "Lista dos IDs das VMs criadas"
  value       = [for vm in proxmox_virtual_environment_vm.vms : vm.vm_id]
}

output "vm_ips" {
  description = "Mapa de IPs das VMs (nome -> IP)"
  value = {
    for name, config in local.processed_vms : name => config.ip_address
  }
}
