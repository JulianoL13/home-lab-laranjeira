# VM outputs
output "vm_ips" {
  description = "IP addresses of created VMs"
  value = {
    web   = module.vm_web.ip_address
    db    = module.vm_db.ip_address
    cache = module.vm_cache.ip_address
  }
}

output "vm_ids" {
  description = "VM IDs"
  value = {
    template = module.template.vm_id
    web      = module.vm_web.vm_id
    db       = module.vm_db.vm_id
    cache    = module.vm_cache.vm_id
  }
}

# Container outputs
output "container_ips" {
  description = "IP addresses of created containers"
  value = {
    web   = module.container_web.ip_address
    db    = module.container_db.ip_address
    cache = module.container_cache.ip_address
  }
}

output "container_ids" {
  description = "Container IDs"
  value = {
    web   = module.container_web.container_id
    db    = module.container_db.container_id
    cache = module.container_cache.container_id
  }
}

# Summary output
output "homelab_summary" {
  description = "Summary of all created resources"
  value = {
    template = {
      id   = module.template.vm_id
      name = module.template.name
      type = "Template"
    }
    vms = {
      for vm_name in keys(local.vms) : vm_name => {
        id   = vm_name == "web" ? module.vm_web.vm_id : (vm_name == "db" ? module.vm_db.vm_id : module.vm_cache.vm_id)
        ip   = local.vms[vm_name].ip_address
        type = "VM"
      }
    }
    containers = {
      for ct_name in keys(local.containers) : ct_name => {
        id   = ct_name == "web" ? module.container_web.container_id : (ct_name == "db" ? module.container_db.container_id : module.container_cache.container_id)
        ip   = local.containers[ct_name].ip_address
        type = "Container"
      }
    }
  }
}