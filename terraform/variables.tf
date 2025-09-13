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
