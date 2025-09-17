variable "vmid" {
  description = "VM ID"
  type        = number
}

variable "name" {
  description = "VM name"
  type        = string
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "template_vmid" {
  description = "Template VM ID to clone from (0 to create template from scratch)"
  type        = number
  default     = 0
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
  description = "Disk size (e.g., '20G')"
  type        = string
}

variable "storage" {
  description = "Storage name"
  type        = string
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

variable "user" {
  description = "Username"
  type        = string
}

variable "ssh_key" {
  description = "SSH public key"
  type        = string
}

variable "image_url" {
  description = "Cloud image URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "image_name" {
  description = "Image filename"
  type        = string
  default     = "ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "image_sha256" {
  description = "Image SHA256 checksum"
  type        = string
  default     = ""
}