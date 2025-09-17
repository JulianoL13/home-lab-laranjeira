terraform {
  required_version = ">= 1.5.0"

  backend "local" {
    path = "../state/terraform.tfstate"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.83"
    }
  }
}
