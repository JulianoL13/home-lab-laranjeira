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
  type = string
}

variable "vmid" {
  type = number
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = string
}

variable "storage" {
  type = string
}

variable "bridge" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "cidr" {
  type = number
}

variable "gateway" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "user" {
  type = string
}

variable "image_url" {
  type = string
}

variable "image_name" {
  type = string
}

variable "net_name" {
  type    = string
  default = "ens18"
}
