variable "vmid" {
  description = "Container ID"
  type        = number
}

variable "name" {
  description = "Container name"
  type        = string
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "template_file_id" {
  description = "LXC template file ID"
  type        = string
}

variable "cores" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "RAM in MB"
  type        = number
}

variable "swap" {
  description = "Swap in MB"
  type        = number
  default     = 512
}

variable "storage" {
  description = "Storage name"
  type        = string
}

variable "rootfs_size" {
  description = "Root filesystem size in GB"
  type        = number
}

variable "bridge" {
  description = "Network bridge"
  type        = string
}

variable "ip_address" {
  description = "IP address"
  type        = string
}

variable "cidr" {
  description = "Network CIDR"
  type        = number
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "password" {
  description = "Root password"
  type        = string
  sensitive   = true
}