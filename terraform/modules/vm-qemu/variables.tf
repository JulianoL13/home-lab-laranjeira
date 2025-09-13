variable "pm_host" {
  description = "Host do Proxmox para conexão SSH"
  type        = string
}

variable "pm_user" {
  description = "Usuário SSH"
  type        = string
}

variable "pm_password" {
  description = "Senha SSH"
  type        = string
  sensitive   = true
}

variable "name" {
  description = "The name of the VM in Proxmox"
  type        = string
}

variable "vmid" {
  description = "Unique VM ID in Proxmox"
  type        = number
}

variable "cores" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "RAM in MB"
  type        = number
}

variable "disk_size" {
  description = "Disk size with unit"
  type        = string
}

variable "storage" {
  description = "Proxmox storage name"
  type        = string
}

variable "bridge" {
  description = "Network bridge"
  type        = string
}

variable "ip_address" {
  description = "Static IP"
  type        = string
}

variable "cidr" {
  description = "Subnet mask"
  type        = number
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "ssh_key" {
  description = "Public SSH key"
  type        = string
}

variable "user" {
  description = "Username to create"
  type        = string
}

variable "image_url" {
  description = "Cloud image download URL"
  type        = string
}

variable "image_name" {
  description = "Local image filename"
  type        = string
}

variable "image_sha256" {
  description = "SHA256 checksum of the cloud image"
  type        = string
}

variable "net_name" {
  description = "Network interface name"
  type        = string
  default     = "ens18"
}
