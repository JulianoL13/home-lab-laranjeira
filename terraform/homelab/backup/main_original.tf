provider "proxmox" {
  endpoint = var.pm_api_url

  api_token = var.pm_api_token_id != null && var.pm_api_token_secret != null ? "${var.pm_api_token_id}=${var.pm_api_token_secret}" : null

  username = var.pm_api_token_id == null ? var.pm_user : null
  password = var.pm_api_token_id == null ? var.pm_password : null

  insecure = true

}

module "homelab_vms" {
  source = "../modules/vm-qemu"

  base_vmid   = 1000
  name_prefix = "homelab"
  node_name   = var.node_name

  create_template = true

  vm_configurations = {
    web = {
      vmid       = 1001
      ip_address = "192.168.0.101"
      memory     = 4096
      cores      = 2
      disk_size  = 50
    }

    db = {
      vmid       = 1002
      ip_address = "192.168.0.102"
      memory     = 2048
      cores      = 1
      disk_size  = 30
    }

    cache = {
      vmid       = 1003
      ip_address = "192.168.0.103"
      memory     = 1024
      cores      = 1
      disk_size  = 20
    }
  }

  default_storage                = var.storage_name
  default_snippet_storage        = var.snippet_storage
  default_initialization_storage = var.initialization_storage
  bridge                         = var.bridge_name
  gateway                        = var.network_gateway
  user                           = "ubuntu"
  ssh_key                        = var.ssh_public_key
  image_url                      = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  image_name                     = "ubuntu-22.04-cloudimg-amd64.img"
}


module "homelab_containers" {
  source = "../modules/lxc-container"

  name_prefix = "homelab"
  node_name   = var.node_name

  ensure_template = true

  container_configurations = {
    web = {
      vmid        = 2001
      ip_address  = "192.168.0.201"
      memory      = 2048
      cores       = 2
      rootfs_size = 10
    }

    db = {
      vmid        = 2002
      ip_address  = "192.168.0.202"
      memory      = 4096
      cores       = 4
      rootfs_size = 20
    }

    cache = {
      vmid        = 2003
      ip_address  = "192.168.0.203"
      memory      = 512
      cores       = 1
      rootfs_size = 5
    }
  }

  default_storage = var.storage_name
  bridge          = var.bridge_name
  gateway         = var.network_gateway
  password        = var.lxc_password
}
