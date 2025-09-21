terraform {
  required_version = ">= 1.6.0"

  backend "local" {
    path = "state/terraform.tfstate"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.83.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure_tls

  ssh {
    agent    = true
    username = var.ssh_username
  }
}
