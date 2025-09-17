# Proxmox connection variables
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user"
  type        = string
  default     = "root@pam"
}

variable "pm_password" {
  description = "Proxmox password (use TF_VAR_pm_password env var for security)"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (recommended over password)"
  type        = string
  default     = null
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret (use TF_VAR_pm_api_token_secret env var)"
  type        = string
  sensitive   = true
  default     = null
}

# Infrastructure variables
variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "storage_name" {
  description = "Storage name for VM/Container disks"
  type        = string
  default     = "Machines"
}

variable "bridge_name" {
  description = "Network bridge name"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "Network gateway IP"
  type        = string
  default     = "192.168.0.1"
}

# Authentication variables
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "lxc_password" {
  description = "Password for LXC containers (use TF_VAR_lxc_password env var)"
  type        = string
  sensitive   = true
}

# Legacy variables for backwards compatibility (marked for deprecation)
variable "cluster_name" {
  description = "[DEPRECATED] Cluster name - not used in simplified version"
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "[DEPRECATED] Template name - managed automatically in simplified version"
  type        = string
  default     = "homelab-template"
}

variable "download_storage" {
  description = "[DEPRECATED] Download storage - uses main storage in simplified version"
  type        = string
  default     = "local"
}

variable "snippet_storage" {
  description = "[DEPRECATED] Snippet storage - uses main storage in simplified version"
  type        = string
  default     = "local"
}

variable "initialization_storage" {
  description = "[DEPRECATED] Initialization storage - uses main storage in simplified version"
  type        = string
  default     = "local"
}

variable "base_ip_range" {
  description = "[DEPRECATED] Base IP range - defined in locals in simplified version"
  type        = string
  default     = "192.168.0"
}