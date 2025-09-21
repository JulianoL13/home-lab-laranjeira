variable "proxmox_api_url" {
  description = "URL do endpoint da API do Proxmox (ex: https://pve01:8006/api2/json)"
  type        = string
}

variable "proxmox_username" {
  description = "Nome de usuário do Proxmox (ex: root@pam)"
  type        = string
}

variable "proxmox_password" {
  description = "Senha do usuário do Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure_tls" {
  description = "Permitir certificados TLS auto-assinados"
  type        = bool
  default     = false
}

variable "ssh_username" {
  description = "Nome de usuário SSH para conexões"
  type        = string
  default     = "root"
}

variable "vm_template_name" {
  description = "Nome do template para VMs"
  type        = string
  default     = "debian-12-cloudinit"
}

variable "container_template_name" {
  description = "Nome do template para containers LXC"
  type        = string
  default     = "debian-12-standard"
}

variable "storage_name" {
  description = "Nome do storage padrão"
  type        = string
  default     = "Machines"
}

variable "storage_name_template" {
  description = "Nome do storage onde guardamos template"
  type        = string
  default     = "local"
}

variable "bridge_name" {
  description = "Nome da bridge de rede padrão"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso às VMs"
  type        = string
  default     = ""
}

variable "default_node_name" {
  description = "Nome do nó padrão do Proxmox"
  type        = string
  default     = "pve01"
}

variable "vm_agent_enabled" {
  description = "Habilitar QEMU Guest Agent nas VMs"
  type        = bool
  default     = true
}

variable "vm_agent_timeout" {
  description = "Timeout do QEMU Guest Agent"
  type        = string
  default     = "60s"
}

variable "vm_cpu_type" {
  description = "Tipo de CPU para VMs"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_cpu_architecture" {
  description = "Arquitetura da CPU para VMs"
  type        = string
  default     = "x86_64"
}

variable "vm_bios_type" {
  description = "Tipo de BIOS para VMs (seabios ou ovmf)"
  type        = string
  default     = "seabios"
}

variable "vm_os_type" {
  description = "Tipo do sistema operacional para VMs"
  type        = string
  default     = "l26"
}

variable "vm_disk_interface" {
  description = "Interface do disco para VMs"
  type        = string
  default     = "scsi0"
}

variable "vm_disk_file_format" {
  description = "Formato do arquivo de disco para VMs"
  type        = string
  default     = "qcow2"
}

variable "vm_disk_cache" {
  description = "Tipo de cache do disco para VMs"
  type        = string
  default     = "writeback"
}

variable "vm_disk_iothread" {
  description = "Habilitar iothread para discos das VMs"
  type        = bool
  default     = true
}

variable "vm_network_model" {
  description = "Modelo da interface de rede para VMs"
  type        = string
  default     = "virtio"
}

variable "vm_vga_type" {
  description = "Tipo de VGA para VMs"
  type        = string
  default     = "serial0"
}

variable "vm_started" {
  description = "Iniciar VMs após criação"
  type        = bool
  default     = true
}

variable "vm_on_boot" {
  description = "Iniciar VMs automaticamente no boot"
  type        = bool
  default     = true
}

variable "vm_protection" {
  description = "Habilitar proteção para VMs"
  type        = bool
  default     = false
}

variable "container_started" {
  description = "Iniciar containers após criação"
  type        = bool
  default     = true
}

variable "container_start_on_boot" {
  description = "Iniciar containers automaticamente no boot"
  type        = bool
  default     = true
}

variable "container_protection" {
  description = "Habilitar proteção para containers"
  type        = bool
  default     = false
}

variable "container_unprivileged" {
  description = "Criar containers como unprivileged"
  type        = bool
  default     = true
}

variable "container_cpu_architecture" {
  description = "Arquitetura da CPU para containers"
  type        = string
  default     = "amd64"
}

variable "container_memory_swap" {
  description = "Memória swap para containers (MB)"
  type        = number
  default     = 0
}

variable "container_os_type" {
  description = "Tipo do sistema operacional para containers"
  type        = string
  default     = "debian"
}

variable "container_network_interface" {
  description = "Nome da interface de rede para containers"
  type        = string
  default     = "veth0"
}

variable "container_features_nesting" {
  description = "Habilitar nesting para containers"
  type        = bool
  default     = true
}

variable "container_features_fuse" {
  description = "Habilitar FUSE para containers"
  type        = bool
  default     = true
}

variable "cloudinit_dns_servers" {
  description = "Servidores DNS para cloud-init"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "cloudinit_dns_domain" {
  description = "Domínio DNS para cloud-init"
  type        = string
  default     = "homelab.local"
}

variable "cloudinit_enable_user_data" {
  description = "Habilitar user-data personalizado do cloud-init"
  type        = bool
  default     = true
}

variable "vm_image_url" {
  description = "URL da imagem cloud-init para VMs"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}

variable "vm_image_filename" {
  description = "Nome do arquivo da imagem para VMs"
  type        = string
  default     = "debian-12-generic-amd64.qcow2"
}

variable "container_image_url" {
  description = "URL da imagem para containers LXC"
  type        = string
  default     = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "container_image_filename" {
  description = "Nome do arquivo da imagem para containers"
  type        = string
  default     = "debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "cloud_init_username" {
  description = "Nome do usuário a ser criado via cloud-init"
  type        = string
  default     = "admin"
}

variable "cloud_init_user_password" {
  description = "Senha do usuário criado via cloud-init"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "root_password" {
  description = "Senha do usuário root"
  type        = string
  default     = "root123"
  sensitive   = true
}
