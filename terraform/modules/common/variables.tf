variable "workload_configurations" {
  description = "Mapa de configurações para cada workload a ser criado"
  type = map(object({
    vmid                   = number
    ip_address            = string
    memory                = optional(number)
    cores                 = optional(number)
    disk_size             = optional(number)
    storage               = optional(string)
    cidr                  = optional(number)
    snippet_storage       = optional(string)
    initialization_storage = optional(string)
    rootfs_size           = optional(number)
    swap                  = optional(number)
    extra_config          = optional(map(any))
  }))
  default = {}
}

variable "name_prefix" {
  description = "Prefixo aplicado aos nomes dos workloads"
  type        = string
}

variable "defaults" {
  description = "Valores padrão para workloads"
  type = object({
    memory    = number
    cores     = number
    disk_size = number
    storage   = string
    cidr      = number
  })
}