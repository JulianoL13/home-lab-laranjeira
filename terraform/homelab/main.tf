# ===== HOMELAB INFRASTRUCTURE CONFIGURATION =====
# Este arquivo define a infraestrutura do homelab usando o padrão de configuração flexível
# Similar ao exemplo AWS fornecido, mas para Proxmox

# ===== CONFIGURAÇÕES DE INSTÂNCIAS =====
# Define as VMs e containers de forma flexível usando locals
locals {
  # Configurações de VMs - padrão similar ao exemplo AWS fornecido
  vm_configs = {
    "web" = { 
      vmid       = 101
      ip_address = "192.168.0.101"
      memory     = 4096
      cores      = 2
      disk_size  = 50
    }
    "db" = { 
      vmid       = 102
      ip_address = "192.168.0.102"
      memory     = 2048
      cores      = 1
      disk_size  = 30
    }
    "cache" = { 
      vmid       = 103
      ip_address = "192.168.0.103"
      memory     = 1024
      cores      = 1
      disk_size  = 20
    }
  }

  # Configurações de containers LXC
  container_configs = {
    "nginx" = {
      vmid        = 201
      ip_address  = "192.168.0.201"
      memory      = 512
      cores       = 1
      rootfs_size = 8
    }
    "redis" = {
      vmid        = 202
      ip_address  = "192.168.0.202"
      memory      = 256
      cores       = 1
      rootfs_size = 4
    }
  }
}

# ===== TEMPLATES (CRIADOS PRIMEIRO) =====
# Templates devem ser criados antes das máquinas, conforme requisito

# Template para VMs
module "vm_templates" {
  source = "../modules/vm-qemu"

  # Configuração do template
  base_vmid       = 9000
  name_prefix     = var.name_prefix
  node_name       = var.node_name
  create_template = true

  # Configurações vazias - apenas cria o template
  vm_configurations = {}

  # Configurações de rede
  bridge  = var.bridge
  gateway = var.gateway
  user    = var.vm_user
  ssh_key = var.ssh_public_key

  # Configurações de imagem
  image_url    = var.vm_image_url
  image_name   = var.vm_image_name
  image_sha256 = var.vm_image_sha256

  # Configurações de storage
  default_storage               = var.default_storage
  default_snippet_storage       = var.snippet_storage
  default_initialization_storage = var.snippet_storage

  # Valores padrão
  default_memory    = 2048
  default_cores     = 2
  default_disk_size = 25
}

# Template para containers (preparação do template LXC)
module "container_templates" {
  source = "../modules/lxc-container"

  name_prefix     = var.name_prefix
  node_name       = var.node_name
  ensure_template = false # Desabilitado conforme comentário no módulo

  # Configurações vazias - apenas prepara o ambiente
  container_configurations = {}

  # Configurações de rede
  bridge   = var.bridge
  gateway  = var.gateway
  password = var.lxc_password

  # Configurações de template
  template_storage = var.template_storage
  template_name    = var.lxc_template_name

  # Configurações de storage
  default_storage = var.default_storage

  # Valores padrão
  default_memory      = 1024
  default_cores       = 1
  default_rootfs_size = 8
}

# ===== MÁQUINAS VIRTUAIS =====
# VMs criadas após os templates usando padrão for_each similar ao AWS

module "vms" {
  source = "../modules/vm-qemu"
  
  # Dependência explícita dos templates
  depends_on = [module.vm_templates]

  # Configuração das VMs usando o padrão local + for_each
  base_vmid         = 9000
  name_prefix       = var.name_prefix
  node_name         = var.node_name
  create_template   = false # Template já foi criado
  vm_configurations = local.vm_configs

  # Configurações de rede
  bridge  = var.bridge
  gateway = var.gateway
  user    = var.vm_user
  ssh_key = var.ssh_public_key

  # Configurações de imagem (usadas pelo template)
  image_url    = var.vm_image_url
  image_name   = var.vm_image_name
  image_sha256 = var.vm_image_sha256

  # Configurações de storage
  default_storage               = var.default_storage
  default_snippet_storage       = var.snippet_storage
  default_initialization_storage = var.snippet_storage

  # Valores padrão
  default_memory    = 2048
  default_cores     = 2
  default_disk_size = 25
}

# ===== CONTAINERS LXC =====
# Containers criados após os templates

module "containers" {
  source = "../modules/lxc-container"
  
  # Dependência explícita dos templates
  depends_on = [module.container_templates]

  name_prefix              = var.name_prefix
  node_name                = var.node_name
  ensure_template          = false
  container_configurations = local.container_configs

  # Configurações de rede
  bridge   = var.bridge
  gateway  = var.gateway
  password = var.lxc_password

  # Configurações de template
  template_storage = var.template_storage
  template_name    = var.lxc_template_name

  # Configurações de storage
  default_storage = var.default_storage

  # Valores padrão
  default_memory      = 1024
  default_cores       = 1
  default_rootfs_size = 8
}