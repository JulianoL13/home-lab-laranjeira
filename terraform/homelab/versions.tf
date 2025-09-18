terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.83.2"
    }
  }
}

# Configuração do provider Proxmox
provider "proxmox" {
  endpoint  = var.pm_api_url
  username  = var.pm_user
  password  = var.pm_password
  
  # Configuração de API token (alternativa recomendada)
  api_token = var.pm_api_token_secret != "" ? var.pm_api_token_secret : null
  
  # Configurações de SSL
  insecure = var.pm_tls_insecure
}