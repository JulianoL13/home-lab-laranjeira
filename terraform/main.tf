resource "proxmox_virtual_environment_download_file" "debian_12_cloud_img" {
  content_type = "import"
  datastore_id = var.storage_name_template
  node_name    = var.default_node_name
  url          = var.vm_image_url
  file_name    = var.vm_image_filename
}

resource "proxmox_virtual_environment_download_file" "debian_12_lxc_template" {
  content_type = "vztmpl"
  datastore_id = var.storage_name_template
  node_name    = var.default_node_name
  url          = var.container_image_url
  file_name    = var.container_image_filename
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  for_each = local.vm_configs

  content_type = "snippets"
  datastore_id = var.storage_name_template
  node_name    = each.value.node_name

  source_raw {
    data = templatefile("${path.module}/cloud-init/user-data.yaml", {
      ssh_public_key           = var.ssh_public_key
      hostname                 = each.key
      cloud_init_username      = var.cloud_init_username
      cloud_init_user_password = var.cloud_init_user_password
      root_password            = var.root_password
    })
    file_name = "user-data-${each.key}.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_meta_data" {
  for_each = local.vm_configs

  content_type = "snippets"
  datastore_id = var.storage_name_template
  node_name    = each.value.node_name

  source_raw {
    data = templatefile("${path.module}/cloud-init/meta-data.yaml", {
      instance_id    = "${each.key}-${each.value.vmid}"
      hostname       = each.key
      ssh_public_key = var.ssh_public_key
      environment    = "homelab"
      role           = try(each.value.tags[0], "server")
      cluster_name   = "homelab-cluster"
      node_type      = contains(each.value.tags, "master") ? "master" : "worker"
      timestamp      = timestamp()
    })
    file_name = "meta-data-${each.key}.yml"
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.vm_configs

  name        = each.key
  vm_id       = each.value.vmid
  node_name   = each.value.node_name
  description = "VM criada via Terraform - ${each.key}"
  tags        = each.value.tags

  started    = var.vm_started
  on_boot    = var.vm_on_boot
  protection = var.vm_protection

  stop_on_destroy = true
  timeout_create  = 1800

  agent {
    enabled = var.vm_agent_enabled
    timeout = var.vm_agent_timeout
  }

  cpu {
    cores        = each.value.cores
    type         = var.vm_cpu_type
    architecture = var.vm_cpu_architecture
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  disk {
    datastore_id = var.storage_name
    interface    = "scsi0"
    size         = each.value.disk_size
    import_from  = proxmox_virtual_environment_download_file.debian_12_cloud_img.id
  }

  network_device {
    bridge   = var.bridge_name
    model    = var.vm_network_model
    firewall = false
  }

  operating_system {
    type = var.vm_os_type
  }

  bios = var.vm_bios_type

  initialization {
    datastore_id = var.storage_name_template

    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = each.value.gateway
      }
    }

    user_account {
      username = each.value.ciuser
      keys     = var.ssh_public_key != "" ? [var.ssh_public_key] : []
    }

    dns {
      servers = var.cloudinit_dns_servers
      domain  = var.cloudinit_dns_domain
    }

    user_data_file_id = var.cloudinit_enable_user_data ? proxmox_virtual_environment_file.cloud_init_user_data[each.key].id : null
    meta_data_file_id = var.cloudinit_enable_user_data ? proxmox_virtual_environment_file.cloud_init_meta_data[each.key].id : null
  }

  serial_device {}

  vga {
    type = var.vm_vga_type
  }

  depends_on = [
    proxmox_virtual_environment_download_file.debian_12_cloud_img,
    proxmox_virtual_environment_file.cloud_init_user_data,
    proxmox_virtual_environment_file.cloud_init_meta_data
  ]
}

resource "proxmox_virtual_environment_container" "containers" {
  for_each = local.container_configs

  vm_id       = each.value.vmid
  node_name   = each.value.node_name
  description = "Container LXC criado via Terraform - ${each.key}"
  tags        = each.value.tags

  started       = var.container_started
  start_on_boot = var.container_start_on_boot
  protection    = var.container_protection
  unprivileged  = var.container_unprivileged

  # Configurações de comportamento durante destroy
  timeout_create = 1800

  features {
    nesting = var.container_features_nesting
    fuse    = var.container_features_fuse
  }

  cpu {
    cores        = each.value.cores
    architecture = var.container_cpu_architecture
  }

  memory {
    dedicated = each.value.memory
    swap      = var.container_memory_swap
  }

  disk {
    datastore_id = var.storage_name
    size         = each.value.disk_size
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_12_lxc_template.id
    type             = var.container_os_type
  }

  network_interface {
    name     = var.container_network_interface
    bridge   = var.bridge_name
    firewall = false
  }

  initialization {
    hostname = each.value.hostname

    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = each.value.gateway
      }
    }

    user_account {
      password = var.root_password
      keys     = var.ssh_public_key != "" ? [var.ssh_public_key] : []
    }

    dns {
      servers = var.cloudinit_dns_servers
      domain  = var.cloudinit_dns_domain
    }
  }

  depends_on = [
    proxmox_virtual_environment_download_file.debian_12_lxc_template,
    proxmox_virtual_environment_vm.vms
  ]
}
