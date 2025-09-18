# ===== PROXMOX CONNECTION VARIABLES =====

variable "pm_api_url" {
  description = "URL da API do Proxmox (ex: https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Usuário do Proxmox (ex: root@pam)"
  type        = string
  default     = ""
}

variable "pm_password" {
  description = "Senha do usuário do Proxmox"
  type        = string
  default     = ""
  sensitive   = true
}



variable "pm_api_token_secret" {
  description = "Token de API do Proxmox (recomendado em vez de senha)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Pular verificação de certificado SSL"
  type        = bool
  default     = true
}

# ===== INFRASTRUCTURE VARIABLES =====

variable "node_name" {
  description = "Nome do nó Proxmox onde os recursos serão criados"
  type        = string
}

variable "name_prefix" {
  description = "Prefixo aplicado aos nomes de todos os recursos"
  type        = string
  default     = "homelab"
}

# ===== NETWORKING VARIABLES =====

variable "bridge" {
  description = "Bridge de rede para conectar VMs e containers"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Gateway padrão para configuração de rede"
  type        = string
}

# ===== VM CONFIGURATION VARIABLES =====

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso às VMs"
  type        = string
}

variable "vm_user" {
  description = "Nome do usuário criado nas VMs via cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "vm_image_url" {
  description = "URL para download da imagem base das VMs"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "vm_image_name" {
  description = "Nome do arquivo da imagem após download"
  type        = string
  default     = "ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "vm_image_sha256" {
  description = "Hash SHA256 da imagem para verificação (deixe vazio para pular)"
  type        = string
  default     = ""
}

# ===== CONTAINER CONFIGURATION VARIABLES =====

variable "lxc_password" {
  description = "Senha do usuário root dos containers"
  type        = string
  sensitive   = true
}

variable "lxc_template_name" {
  description = "Nome do template LXC"
  type        = string
  default     = "ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

# ===== STORAGE VARIABLES =====

variable "default_storage" {
  description = "Storage padrão para discos"
  type        = string
  default     = "machines"
}

variable "snippet_storage" {
  description = "Storage para arquivos cloud-config"
  type        = string
  default     = "machines"
}

variable "template_storage" {
  description = "Storage para templates"
  type        = string
  default     = "local"
}