provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = var.pm_api_token_id != null && var.pm_api_token_secret != null ? "${var.pm_api_token_id}=${var.pm_api_token_secret}" : null
  username  = var.pm_api_token_id == null ? var.pm_user : null
  password  = var.pm_api_token_id == null ? var.pm_password : null
  insecure  = true
}

locals {
  # Global defaults
  defaults = {
    node_name = var.node_name
    bridge    = var.bridge_name
    gateway   = var.network_gateway
    cidr      = 24
    storage   = var.storage_name
    ssh_key   = var.ssh_public_key
    user      = "ubuntu"
  }

  # Template configuration
  template = {
    vmid      = 1000
    name      = "homelab-template"
    memory    = 2048
    cores     = 2
    disk_size = "25G"
  }

  # VM definitions
  vms = {
    web = {
      vmid       = 1001
      name       = "homelab-web"
      ip_address = "192.168.0.101"
      memory     = 4096
      cores      = 2
      disk_size  = "50G"
    }

    db = {
      vmid       = 1002
      name       = "homelab-db"
      ip_address = "192.168.0.102"
      memory     = 2048
      cores      = 1
      disk_size  = "30G"
    }

    cache = {
      vmid       = 1003
      name       = "homelab-cache"
      ip_address = "192.168.0.103"
      memory     = 1024
      cores      = 1
      disk_size  = "20G"
    }
  }

  # Container definitions
  containers = {
    web = {
      vmid        = 2001
      name        = "homelab-web-ct"
      ip_address  = "192.168.0.201"
      memory      = 2048
      cores       = 2
      rootfs_size = 10
      swap        = 512
    }

    db = {
      vmid        = 2002
      name        = "homelab-db-ct"
      ip_address  = "192.168.0.202"
      memory      = 4096
      cores       = 4
      rootfs_size = 20
      swap        = 1024
    }

    cache = {
      vmid        = 2003
      name        = "homelab-cache-ct"
      ip_address  = "192.168.0.203"
      memory      = 512
      cores       = 1
      rootfs_size = 5
      swap        = 256
    }
  }
}

# Template VM (created from cloud image)
module "template" {
  source = "../modules/simple-vm"

  vmid          = local.template.vmid
  name          = local.template.name
  node_name     = local.defaults.node_name
  template_vmid = 0 # Create from scratch
  cores         = local.template.cores
  memory        = local.template.memory
  disk_size     = local.template.disk_size
  storage       = local.defaults.storage
  bridge        = local.defaults.bridge
  ip_address    = "192.168.0.100" # Temporary IP for template
  cidr          = local.defaults.cidr
  gateway       = local.defaults.gateway
  user          = local.defaults.user
  ssh_key       = local.defaults.ssh_key
  image_url     = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  image_name    = "ubuntu-22.04-server-cloudimg-amd64.img"
}

# VMs (cloned from template)
module "vm_web" {
  source = "../modules/simple-vm"

  vmid          = local.vms.web.vmid
  name          = local.vms.web.name
  node_name     = local.defaults.node_name
  template_vmid = local.template.vmid
  cores         = local.vms.web.cores
  memory        = local.vms.web.memory
  disk_size     = local.vms.web.disk_size
  storage       = local.defaults.storage
  bridge        = local.defaults.bridge
  ip_address    = local.vms.web.ip_address
  cidr          = local.defaults.cidr
  gateway       = local.defaults.gateway
  user          = local.defaults.user
  ssh_key       = local.defaults.ssh_key

  depends_on = [module.template]
}

module "vm_db" {
  source = "../modules/simple-vm"

  vmid          = local.vms.db.vmid
  name          = local.vms.db.name
  node_name     = local.defaults.node_name
  template_vmid = local.template.vmid
  cores         = local.vms.db.cores
  memory        = local.vms.db.memory
  disk_size     = local.vms.db.disk_size
  storage       = local.defaults.storage
  bridge        = local.defaults.bridge
  ip_address    = local.vms.db.ip_address
  cidr          = local.defaults.cidr
  gateway       = local.defaults.gateway
  user          = local.defaults.user
  ssh_key       = local.defaults.ssh_key

  depends_on = [module.template]
}

module "vm_cache" {
  source = "../modules/simple-vm"

  vmid          = local.vms.cache.vmid
  name          = local.vms.cache.name
  node_name     = local.defaults.node_name
  template_vmid = local.template.vmid
  cores         = local.vms.cache.cores
  memory        = local.vms.cache.memory
  disk_size     = local.vms.cache.disk_size
  storage       = local.defaults.storage
  bridge        = local.defaults.bridge
  ip_address    = local.vms.cache.ip_address
  cidr          = local.defaults.cidr
  gateway       = local.defaults.gateway
  user          = local.defaults.user
  ssh_key       = local.defaults.ssh_key

  depends_on = [module.template]
}

# Containers
module "container_web" {
  source = "../modules/simple-container"

  vmid             = local.containers.web.vmid
  name             = local.containers.web.name
  node_name        = local.defaults.node_name
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores            = local.containers.web.cores
  memory           = local.containers.web.memory
  swap             = local.containers.web.swap
  storage          = local.defaults.storage
  rootfs_size      = local.containers.web.rootfs_size
  bridge           = local.defaults.bridge
  ip_address       = local.containers.web.ip_address
  cidr             = local.defaults.cidr
  gateway          = local.defaults.gateway
  password         = var.lxc_password
}

module "container_db" {
  source = "../modules/simple-container"

  vmid             = local.containers.db.vmid
  name             = local.containers.db.name
  node_name        = local.defaults.node_name
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores            = local.containers.db.cores
  memory           = local.containers.db.memory
  swap             = local.containers.db.swap
  storage          = local.defaults.storage
  rootfs_size      = local.containers.db.rootfs_size
  bridge           = local.defaults.bridge
  ip_address       = local.containers.db.ip_address
  cidr             = local.defaults.cidr
  gateway          = local.defaults.gateway
  password         = var.lxc_password
}

module "container_cache" {
  source = "../modules/simple-container"

  vmid             = local.containers.cache.vmid
  name             = local.containers.cache.name
  node_name        = local.defaults.node_name
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores            = local.containers.cache.cores
  memory           = local.containers.cache.memory
  swap             = local.containers.cache.swap
  storage          = local.defaults.storage
  rootfs_size      = local.containers.cache.rootfs_size
  bridge           = local.defaults.bridge
  ip_address       = local.containers.cache.ip_address
  cidr             = local.defaults.cidr
  gateway          = local.defaults.gateway
  password         = var.lxc_password
}