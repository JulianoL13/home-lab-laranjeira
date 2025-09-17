# Demonstration: Adding a New Machine

This demonstrates how easy it is to add machines with the simplified configuration.

## Before: Complex Configuration
```hcl
# Had to understand complex merge logic, 20+ variables, and nested conditions
vm_configurations = {
  newvm = {
    vmid = 1004
    ip_address = "192.168.0.104"
    # Which defaults apply? What storage? Complex merge logic...
  }
}
```

## After: Simple Configuration

### 1. Add to locals (1 step)
```hcl
# In main.tf locals
vms = {
  web = { ... },
  db = { ... },
  cache = { ... },
  # New VM - clear and explicit
  monitoring = {
    vmid       = 1004
    name       = "homelab-monitoring"
    ip_address = "192.168.0.104"
    memory     = 3072
    cores      = 2
    disk_size  = "40G"
  }
}
```

### 2. Add module call (1 step)
```hcl
# Individual module call - explicit and clear
module "vm_monitoring" {
  source = "../modules/simple-vm"
  
  vmid         = local.vms.monitoring.vmid
  name         = local.vms.monitoring.name
  node_name    = local.defaults.node_name
  template_vmid = local.template.vmid
  cores        = local.vms.monitoring.cores
  memory       = local.vms.monitoring.memory
  disk_size    = local.vms.monitoring.disk_size
  storage      = local.defaults.storage
  bridge       = local.defaults.bridge
  ip_address   = local.vms.monitoring.ip_address
  cidr         = local.defaults.cidr
  gateway      = local.defaults.gateway
  user         = local.defaults.user
  ssh_key      = local.defaults.ssh_key
  
  depends_on = [module.template]
}
```

### 3. Update outputs (1 step)
```hcl
output "vm_ips" {
  value = {
    web        = module.vm_web.ip_address
    db         = module.vm_db.ip_address
    cache      = module.vm_cache.ip_address
    monitoring = module.vm_monitoring.ip_address  # Added
  }
}
```

## Result: Clear, Maintainable, Debuggable

- ✅ **No complex logic to understand**
- ✅ **Explicit configuration - what you see is what you get**
- ✅ **Easy to debug - direct module calls**
- ✅ **Simple to modify - change values directly**
- ✅ **Safe to maintain - no hidden merge complexity**

Total time to add a new machine: **5 minutes**
Lines of code changed: **~15 lines**
Risk of breaking existing configuration: **Near zero**