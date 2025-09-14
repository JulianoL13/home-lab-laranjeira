output "vm_id" {
  description = "ID da VM template criada"
  value       = proxmox_virtual_environment_vm.template.vm_id
}

output "vm_ip" {
  description = "Endereço IP configurado"
  value       = var.ip_address
}

output "template_name" {
  description = "Nome do template criado"
  value       = proxmox_virtual_environment_vm.template.name
}

output "cloud_image_id" {
  description = "ID da imagem cloud baixada"
  value       = proxmox_virtual_environment_download_file.cloud_image.id
}
