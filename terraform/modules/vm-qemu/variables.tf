variable "base_vmid" {
  description = "VM ID base usado para o template"
  type        = number
}

variable "name_prefix" {
  description = "Prefixo aplicado aos nomes das VMs e template"
  type        = string
}

variable "node_name" {
  description = "Nome do nó Proxmox onde os recursos serão criados"
  type        = string
}

variable "create_template" {
  description = "Se deve criar template base e arquivos relacionados"
  type        = bool
  default     = true
}

variable "vm_configurations" {
  description = "Mapa de configurações para cada VM a ser criada"
  type = map(object({
    vmid                   = number
    ip_address             = string
    memory                 = optional(number)
    cores                  = optional(number)
    disk_size              = optional(number)
    storage                = optional(string)
    snippet_storage        = optional(string)
    initialization_storage = optional(string)
    cidr                   = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, config in var.vm_configurations :
      config.ip_address != null && config.ip_address != ""
    ])
    error_message = "Todas as VMs devem ter ip_address definido e não pode ser vazio."
  }

  validation {
    condition = alltrue([
      for name, config in var.vm_configurations :
      config.vmid != null
    ])
    error_message = "Todas as VMs devem ter vmid definido."
  }
}

variable "default_memory" {
  description = "Memória padrão em MB para VMs que não especificarem"
  type        = number
  default     = 2048
}

variable "default_cores" {
  description = "Número de cores padrão para VMs que não especificarem"
  type        = number
  default     = 2
}

variable "default_disk_size" {
  description = "Tamanho padrão do disco em GB para VMs que não especificarem"
  type        = number
  default     = 25
}

variable "default_storage" {
  description = "Storage padrão para discos das VMs"
  type        = string
}

variable "default_snippet_storage" {
  description = "Storage padrão para arquivos cloud-config"
  type        = string
}

variable "default_initialization_storage" {
  description = "Storage padrão para arquivos de inicialização"
  type        = string
}

variable "bridge" {
  description = "Bridge de rede para conectar as VMs"
  type        = string
}

variable "gateway" {
  description = "Gateway padrão para configuração de rede das VMs"
  type        = string
}

variable "user" {
  description = "Nome do usuário criado nas VMs via cloud-init"
  type        = string
}

variable "ssh_key" {
  description = "Chave SSH pública adicionada ao usuário das VMs"
  type        = string
}

variable "image_url" {
  description = "URL para download da imagem base do template"
  type        = string
}

variable "image_name" {
  description = "Nome do arquivo da imagem após download"
  type        = string
}

variable "image_sha256" {
  description = "Hash SHA256 da imagem para verificação (vazio para pular)"
  type        = string
  default     = ""
}

# Variáveis para valores anteriormente hardcoded
variable "default_cidr" {
  description = "CIDR padrão para configuração de rede"
  type        = number
  default     = 24
}

variable "cpu_type" {
  description = "Tipo de CPU para as VMs"
  type        = string
  default     = "host"
}

variable "disk_interface" {
  description = "Interface do disco para as VMs"
  type        = string
  default     = "scsi0"
}

variable "scsi_hardware" {
  description = "Hardware SCSI para as VMs"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "network_model" {
  description = "Modelo da interface de rede"
  type        = string
  default     = "virtio"
}

variable "agent_enabled" {
  description = "Se o agente QEMU deve ser habilitado"
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Se as VMs devem iniciar automaticamente com o boot"
  type        = bool
  default     = true
}

variable "started" {
  description = "Se as VMs devem estar iniciadas após criação"
  type        = bool
  default     = true
}
