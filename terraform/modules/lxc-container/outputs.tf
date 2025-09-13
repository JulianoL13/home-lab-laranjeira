output "container_id" {
  description = "ID do container no Proxmox"
  value       = proxmox_lxc.container.vmid
}

output "container_ip" {
  description = "Endereço IP do container"
  value       = var.ip_address
}
