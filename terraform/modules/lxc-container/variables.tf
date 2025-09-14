variable "hostname" {
  description = "Nome do container"
  type        = string
}

variable "vmid" {
  description = "ID único do container"
  type        = number
}

variable "target_node" {
  description = "Nó do cluster Proxmox"
  type        = string
}

variable "ostemplate" {
  description = "Template do sistema operacional"
  type        = string
}

variable "description" {
  description = "Descrição do container"
  type        = string
  default     = "Container criado via Terraform"
}

variable "rootfs_storage" {
  description = "Storage onde o rootfs será criado"
  type        = string
}

variable "rootfs_size" {
  description = "Tamanho do disco rootfs (ex: 8G)"
  type        = string
}

variable "cores" {
  description = "Quantidade de vCPUs"
  type        = number
}

variable "memory" {
  description = "Memória RAM em MB"
  type        = number
}

variable "swap" {
  description = "Tamanho da swap em MB"
  type        = number
  default     = 0
}

variable "bridge" {
  description = "Bridge de rede"
  type        = string
}

variable "ip_address" {
  description = "Endereço IPv4"
  type        = string
}

variable "cidr" {
  description = "Máscara de rede"
  type        = number
}

variable "gateway" {
  description = "Gateway padrão"
  type        = string
}

variable "net_name" {
  description = "Nome da interface de rede"
  type        = string
  default     = "eth0"
}

variable "unprivileged" {
  description = "Container não privilegiado"
  type        = bool
  default     = true
}

variable "password" {
  description = "Senha do usuário root"
  type        = string
  sensitive   = true
}

variable "mounts" {
  description = "Pontos de montagem adicionais"
  type = list(object({
    slot    = number
    storage = string
    mp      = string
    size    = string
    volume  = optional(string)
  }))
  default = []
}
