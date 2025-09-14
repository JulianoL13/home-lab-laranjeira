variable "node_name" {
  description = "Proxmox node name"
  type        = string
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
  description = "Disk size in gigabytes"
  type        = number
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
