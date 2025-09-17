output "container_id" {
  description = "Container ID"
  value       = proxmox_virtual_environment_container.container.vm_id
}

output "name" {
  description = "Container name"
  value       = var.name
}

output "ip_address" {
  description = "Container IP address"
  value       = var.ip_address
}

output "container_resource" {
  description = "Full container resource"
  value       = proxmox_virtual_environment_container.container
}