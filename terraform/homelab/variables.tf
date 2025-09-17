variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user"
  type        = string
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = null
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "cluster_name" {
  description = "Proxmox cluster name"
  type        = string
}

variable "template_name" {
  description = "VM template name"
  type        = string
}

# Variáveis para os exemplos
variable "ssh_public_key" {
  description = "Chave pública SSH para acesso às VMs"
  type        = string
}

variable "lxc_password" {
  description = "Senha para containers LXC"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Nome do nó Proxmox"
  type        = string
  default     = "pve"
}

variable "storage_name" {
  description = "Nome do storage Proxmox para discos"
  type        = string
  default     = "Machines"
}

variable "download_storage" {
  description = "Storage para downloads de imagens e ISOs"
  type        = string
  default     = "local"
}

variable "snippet_storage" {
  description = "Storage para snippets cloud-init"
  type        = string
  default     = "local"
}

variable "initialization_storage" {
  description = "Storage para arquivos de inicialização"
  type        = string
  default     = "local"
}

variable "bridge_name" {
  description = "Nome da bridge de rede"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "Gateway da rede"
  type        = string
  default     = "192.168.0.1"
}

variable "base_ip_range" {
  description = "Range base de IPs (ex: 192.168.1)"
  type        = string
  default     = "192.168.0"
}
