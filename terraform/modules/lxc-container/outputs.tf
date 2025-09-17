output "containers" {
  description = "Informações dos containers criados"
  value = {
    for name, container in proxmox_virtual_environment_container.containers : name => {
      vm_id      = container.vm_id
      name       = container.initialization[0].hostname
      ip_address = local.processed_containers[name].ip_address
      memory     = container.memory[0].dedicated
      cores      = container.cpu[0].cores
    }
  }
}

output "container_ids" {
  description = "Lista dos IDs dos containers criados"
  value       = [for container in proxmox_virtual_environment_container.containers : container.vm_id]
}

output "container_ips" {
  description = "Mapa de IPs dos containers (nome -> IP)"
  value       = {
    for name, config in local.processed_containers : name => config.ip_address
  }
}

output "template_downloaded" {
  description = "Se o template LXC foi baixado"
  value       = var.ensure_template
}