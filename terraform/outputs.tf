output "vm_details" {
  description = "Detalhes das VMs criadas"
  value = {
    for name, vm in proxmox_virtual_environment_vm.vms : name => {
      vmid       = vm.vm_id
      name       = vm.name
      node_name  = vm.node_name
      ip_address = local.vm_configs[name].ip_address
      gateway    = local.vm_configs[name].gateway
      cores      = local.vm_configs[name].cores
      memory     = local.vm_configs[name].memory
      disk_size  = local.vm_configs[name].disk_size
      tags       = vm.tags
      status     = vm.started ? "running" : "stopped"
    }
  }
}

output "vm_ips" {
  description = "IPs das VMs criadas"
  value = {
    for name, config in local.vm_configs : name => config.ip_address
  }
}

output "vm_ssh_commands" {
  description = "Comandos SSH para acessar as VMs"
  value = {
    for name, config in local.vm_configs : name =>
    "ssh ${config.ciuser}@${split("/", config.ip_address)[0]}"
  }
}

output "container_details" {
  description = "Detalhes dos containers criados"
  value = {
    for name, container in proxmox_virtual_environment_container.containers : name => {
      vmid       = container.vm_id
      hostname   = local.container_configs[name].hostname
      node_name  = container.node_name
      ip_address = local.container_configs[name].ip_address
      gateway    = local.container_configs[name].gateway
      cores      = local.container_configs[name].cores
      memory     = local.container_configs[name].memory
      disk_size  = local.container_configs[name].disk_size
      tags       = container.tags
      status     = container.started ? "running" : "stopped"
    }
  }
}

output "container_ips" {
  description = "IPs dos containers criados"
  value = {
    for name, config in local.container_configs : name => config.ip_address
  }
}

output "container_ssh_commands" {
  description = "Comandos SSH para acessar os containers"
  value = {
    for name, config in local.container_configs : name =>
    "ssh root@${split("/", config.ip_address)[0]}"
  }
}

output "infrastructure_summary" {
  description = "Resumo da infraestrutura criada"
  value = {
    total_vms        = length(local.vm_configs)
    total_containers = length(local.container_configs)
    total_resources  = length(local.vm_configs) + length(local.container_configs)

    vm_names        = keys(local.vm_configs)
    container_names = keys(local.container_configs)

    nodes_used = distinct(concat(
      [for config in local.vm_configs : config.node_name],
      [for config in local.container_configs : config.node_name]
    ))
  }
}

output "ansible_inventory" {
  description = "Inventário para uso com Ansible"
  value = {
    all = {
      children = {
        vms = {
          hosts = {
            for name, config in local.vm_configs : name => {
              ansible_host = split("/", config.ip_address)[0]
              ansible_user = config.ciuser
              vmid         = config.vmid
              node_name    = config.node_name
            }
          }
        }
        containers = {
          hosts = {
            for name, config in local.container_configs : name => {
              ansible_host = split("/", config.ip_address)[0]
              ansible_user = "root"
              vmid         = config.vmid
              node_name    = config.node_name
            }
          }
        }
        k3s_masters = {
          hosts = {
            for name, config in local.vm_configs : name => {
              ansible_host = split("/", config.ip_address)[0]
              ansible_user = config.ciuser
            } if contains(config.tags, "master")
          }
        }
        k3s_workers = {
          hosts = {
            for name, config in local.vm_configs : name => {
              ansible_host = split("/", config.ip_address)[0]
              ansible_user = config.ciuser
            } if contains(config.tags, "worker")
          }
        }
      }
    }
  }
}
