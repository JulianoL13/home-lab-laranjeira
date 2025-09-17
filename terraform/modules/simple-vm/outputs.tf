output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "ip_address" {
  description = "VM IP address"
  value       = var.ip_address
}

output "vm_resource" {
  description = "Full VM resource"
  value       = proxmox_virtual_environment_vm.vm
}