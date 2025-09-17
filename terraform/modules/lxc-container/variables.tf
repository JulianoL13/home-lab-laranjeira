variable "name_prefix" {
  description = "Prefixo aplicado aos nomes dos containers"
  type        = string
}

variable "node_name" {
  description = "Nome do nó Proxmox onde os containers serão criados"
  type        = string
}

variable "ensure_template" {
  description = "Se deve garantir que o template LXC existe"
  type        = bool
  default     = true
}

variable "container_configurations" {
  description = "Mapa de configurações para cada container a ser criado"
  type = map(object({
    vmid        = number
    ip_address  = string
    memory      = optional(number)
    cores       = optional(number)
    rootfs_size = optional(number)
    storage     = optional(string)
    swap        = optional(number)
    cidr        = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, config in var.container_configurations :
      config.ip_address != null && config.ip_address != ""
    ])
    error_message = "Todos os containers devem ter ip_address definido e não pode ser vazio."
  }

  validation {
    condition = alltrue([
      for name, config in var.container_configurations :
      config.vmid != null
    ])
    error_message = "Todos os containers devem ter vmid definido."
  }
}

variable "default_memory" {
  description = "Memória padrão em MB para containers que não especificarem"
  type        = number
  default     = 1024
}

variable "default_cores" {
  description = "Número de cores padrão para containers que não especificarem"
  type        = number
  default     = 1
}

variable "default_rootfs_size" {
  description = "Tamanho padrão do rootfs em GB para containers que não especificarem"
  type        = number
  default     = 8
}

variable "default_storage" {
  description = "Storage padrão para containers"
  type        = string
}

variable "default_swap" {
  description = "Swap padrão em MB para containers que não especificarem"
  type        = number
  default     = 256
}

variable "template_storage" {
  description = "Storage onde o template LXC será baixado"
  type        = string
  default     = "local"
}

variable "template_url" {
  description = "URL para download do template LXC"
  type        = string
  default     = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "template_name" {
  description = "Nome do arquivo do template LXC"
  type        = string
  default     = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "bridge" {
  description = "Bridge de rede para conectar os containers"
  type        = string
}

variable "gateway" {
  description = "Gateway padrão para configuração de rede dos containers"
  type        = string
}

variable "password" {
  description = "Senha do usuário root dos containers"
  type        = string
  sensitive   = true
}

# Variáveis para valores anteriormente hardcoded
variable "default_cidr" {
  description = "CIDR padrão para configuração de rede"
  type        = number
  default     = 24
}

variable "unprivileged" {
  description = "Se os containers devem ser unprivileged"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Se os containers devem iniciar automaticamente com o boot"
  type        = bool
  default     = true
}

variable "started" {
  description = "Se os containers devem estar iniciados após criação"
  type        = bool
  default     = true
}

variable "os_type" {
  description = "Tipo do sistema operacional do template"
  type        = string
  default     = "ubuntu"
}

variable "network_interface_name" {
  description = "Nome da interface de rede do container"
  type        = string
  default     = "eth0"
}

variable "network_interface_enabled" {
  description = "Se a interface de rede deve estar habilitada"
  type        = bool
  default     = true
}
