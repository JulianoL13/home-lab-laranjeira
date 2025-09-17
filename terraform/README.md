# Terraform Homelab - Extensibilidade com Extra Config

Este projeto utiliza uma abordagem inovadora para permitir máxima flexibilidade na configuração de recursos Proxmox através de **blocos de configuração extras**.

## 🎯 Conceito: Bloco `extra_config`

Os módulos são projetados para aceitar **qualquer propriedade** do provider Proxmox através de um bloco unificado `extra_config`. Isso significa que você pode adicionar configurações avançadas diretamente no `main.tf` principal sem modificar os módulos.

## 📋 Como Funciona

### 1. Estrutura Base (Implementada)

```terraform
# locals no módulo
locals {
  processed_vms = {
    for name, config in var.vm_configurations :
    name => merge({
      # Defaults estruturados
      memory     = var.default_memory
      cores      = var.default_cores
      disk_size  = var.default_disk_size
    }, config, {
      # Valores sempre calculados
      ip_with_cidr = "${config.ip_address}/${var.default_cidr}"
      vm_name      = "${var.name_prefix}-${name}"
      
      # Bloco de configurações extras
      extra_config = lookup(config, "extra_config", {})
    })
  }
}
```

### 2. Recursos com Lookup no Bloco

```terraform
# Resource no módulo
resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.processed_vms

  # Propriedades essenciais
  name      = each.value.vm_name
  vm_id     = each.value.vmid
  node_name = var.node_name
  
  # Propriedades do bloco extra_config
  protection = lookup(each.value.extra_config, "protection", false)
  bios       = lookup(each.value.extra_config, "bios", "seabios")
  tags       = lookup(each.value.extra_config, "tags", [])
  
  network_device {
    bridge      = var.bridge
    model       = var.network_model
    mac_address = lookup(each.value.extra_config, "mac_address", null)
    vlan_id     = lookup(each.value.extra_config, "vlan_id", null)
  }
}
```

## 🚀 Uso Prático

### Configuração Básica (Sem extras)

```terraform
vm_configurations = {
  web = {
    vmid       = 1001
    ip_address = "192.168.0.101"
    memory     = 4096
    cores      = 2
    disk_size  = 50
  }
}
```

### Configuração Avançada (Com bloco extra_config)

```terraform
vm_configurations = {
  web = {
    vmid       = 1001
    ip_address = "192.168.0.101"
    memory     = 4096
    cores      = 2
    disk_size  = 50
    
    # Bloco unificado de configurações extras
    extra_config = {
      # Sistema
      protection    = true
      bios         = "ovmf"
      machine      = "q35"
      description  = "Servidor Web de Produção"
      tags         = ["web", "production"]
      
      # Hardware
      cpu_sockets  = 2
      disk_cache   = "none"
      disk_ssd     = true
      
      # Rede
      mac_address  = "02:00:00:00:00:01"
      vlan_id      = 100
      
      # Recursos extras
      additional_disks = [
        {
          datastore_id = "fast-ssd"
          size         = 100
          interface    = "scsi1"
        }
      ]
    }
  },
  
  db = {
    vmid       = 1002
    ip_address = "192.168.0.102"
    memory     = 8192
    cores      = 4
    disk_size  = 100
    
    extra_config = {
      protection     = true
      cpu_sockets    = 2
      disk_iothread  = true
      memory_shared  = 1024
      description    = "Database server with high I/O"
    }
  }
}
```

## 🔧 Workflow de Extensão

### Passo 1: Adicionar Propriedade no Bloco

```terraform
# homelab/main.tf
vm_configurations = {
  web = {
    vmid = 1001
    # ... configurações básicas ...
    
    extra_config = {
      nova_propriedade = "valor"  # ← Nova propriedade no bloco
    }
  }
}
```

### Passo 2: Funciona Automaticamente! ✅

O módulo já implementa `lookup()` para as propriedades mais comuns. Se a propriedade não estiver implementada, ela será ignorada silenciosamente.

### Passo 3: Implementar Lookup (opcional)

Se quiser suporte a uma propriedade específica:

```terraform
# modules/vm-qemu/main.tf
resource "proxmox_virtual_environment_vm" "vms" {
  # ... configurações existentes ...
  
  nova_propriedade = lookup(each.value.extra_config, "nova_propriedade", "default")
  #                         ^                    ^                     ^
  #                    bloco extra_config   nome da chave        valor padrão
}
```

### Não precisa modificar:
- ❌ Variáveis do módulo
- ❌ Locals ou merge()
- ❌ Documentação (até você querer)
- ❌ Outputs

## 📚 Propriedades Suportadas/Possíveis

### VM - Propriedades Principais
```terraform
# Controle
protection      = true/false
on_boot         = true/false
started         = true/false
template        = true/false

# Hardware
bios            = "seabios" | "ovmf"
machine         = "pc" | "q35"
cpu_sockets     = number
cpu_type        = "host" | "x86-64-v2-AES"
memory_shared   = number (MB)

# Rede
mac_address     = "02:00:00:00:00:01"
vlan_id         = number
network_mtu     = number
network_firewall = true/false

# Disco
disk_cache      = "none" | "writethrough" | "writeback"
disk_ssd        = true/false
disk_iothread   = true/false
disk_discard    = true/false

# Metadados
description     = "string"
tags            = ["tag1", "tag2"]
```

### Blocos Avançados
```terraform
# Discos adicionais
additional_disks = [
  {
    datastore_id = "local-lvm"
    size         = 50
    interface    = "scsi1"
    cache        = "none"
  }
]

# Interfaces de rede extras
additional_networks = [
  {
    bridge  = "vmbr1"
    vlan_id = 200
    mac     = "02:00:00:00:00:02"
  }
]
```

## 🏗️ Estado Atual dos Módulos

### ✅ VM Module (`modules/vm-qemu/`)
- **Base implementada**: merge() funcional com extra_config
- **Propriedades extra_config**: 25+ propriedades implementadas
- **Lookup implementados**: 
  - Sistema: protection, bios, machine, description, tags
  - CPU: cpu_sockets, cpu_flags, cpu_architecture  
  - Memória: memory_floating, memory_shared
  - Disco: disk_cache, disk_ssd, disk_iothread, disk_discard, etc.
  - Rede: mac_address, vlan_id, network_mtu, network_firewall
  - Avançado: additional_disks, additional_networks

### ✅ LXC Module (`modules/lxc-container/`)
- **Base implementada**: merge() funcional com extra_config
- **Propriedades extra_config**: 15+ propriedades implementadas
- **Lookup implementados**:
  - Sistema: protection, description, tags
  - CPU: cpu_units
  - Rede: mac_address, vlan_id, network_mtu, network_firewall
  - DNS: dns_servers, dns_domain
  - SSH: ssh_keys
  - Avançado: additional_mount_points, additional_networks

## 📖 Exemplos Completos

### Configuração de Produção
```terraform
module "homelab_vms" {
  source = "../modules/vm-qemu"
  
  vm_configurations = {
    nginx-lb = {
      vmid        = 1001
      ip_address  = "192.168.0.101"
      memory      = 2048
      cores       = 2
      disk_size   = 30
      
      # Configurações extras para VM
      extra_config = {
        protection  = true
        bios        = "ovmf"
        mac_address = "02:00:00:00:01:01"
        tags        = ["loadbalancer", "production", "nginx"]
        description = "Nginx Load Balancer - Production"
        disk_cache  = "none"
        disk_ssd    = true
      }
    }
    
    db-primary = {
      vmid        = 1002
      ip_address  = "192.168.0.102"
      memory      = 8192
      cores       = 4
      disk_size   = 100
      
      extra_config = {
        protection     = true
        cpu_sockets    = 2
        disk_iothread  = true
        mac_address    = "02:00:00:00:01:02"
        tags           = ["database", "primary", "production"]
        description    = "PostgreSQL Primary Database"
        
        # Discos adicionais para dados
        additional_disks = [
          {
            datastore_id = "fast-ssd"
            size         = 200
            interface    = "scsi1"
            cache        = "none"
            ssd          = true
          }
        ]
      }
    }
  }
}

module "homelab_containers" {
  source = "../modules/lxc-container"
  
  container_configurations = {
    web-frontend = {
      vmid        = 2001
      ip_address  = "192.168.0.201"
      memory      = 1024
      cores       = 2
      rootfs_size = 15
      
      # Configurações extras para Container
      extra_config = {
        protection      = true
        description     = "Frontend Web Container"
        tags            = ["web", "frontend", "production"]
        mac_address     = "02:00:00:00:02:01"
        vlan_id         = 100
        dns_servers     = ["8.8.8.8", "8.8.4.4"]
        dns_domain      = "homelab.local"
        
        # Mount points adicionais
        additional_mount_points = [
          {
            volume = "nfs-storage:50"
            path   = "/var/www"
            backup = true
          }
        ]
      }
    }
    
    redis-cache = {
      vmid        = 2002
      ip_address  = "192.168.0.202"
      memory      = 512
      cores       = 1
      rootfs_size = 8
      
      extra_config = {
        description = "Redis Cache Container"
        tags        = ["cache", "redis"]
        cpu_units   = 512
      }
    }
  }
}
```

### Configuração de Desenvolvimento
```terraform
module "homelab_vms" {
  source = "../modules/vm-qemu"
  
  vm_configurations = {
    dev-web = {
      vmid       = 1101
      ip_address = "192.168.0.111"
      memory     = 1024
      cores      = 1
      disk_size  = 20
      
      # Configurações de dev (mais relaxadas)
      protection = false
      on_boot    = false
      tags       = ["development", "web"]
      description = "Development Web Server"
    }
  }
}
```

## 🔍 Troubleshooting

### Propriedade não funciona?

1. **Verifique se o lookup() foi implementado no módulo**:
   ```bash
   grep -r "nova_propriedade" modules/vm-qemu/
   ```

2. **Implemente o lookup()**:
   ```terraform
   nova_propriedade = lookup(each.value, "nova_propriedade", "default")
   ```

3. **Teste com terraform plan**:
   ```bash
   terraform plan
   ```

### Debug do merge()

Para verificar o que está sendo processado:

```terraform
# Adicione um output temporário
output "debug_processed_vms" {
  value = local.processed_vms
}
```

## 📈 Roadmap

- [ ] Implementar lookups mais comuns (mac_address, protection, bios)
- [ ] Criar validações para propriedades críticas
- [ ] Documentar todos os lookups implementados
- [ ] Criar exemplos para casos de uso específicos
- [ ] Implementar testes automatizados

## 🤝 Contribuindo

Para adicionar suporte a uma nova propriedade:

1. **Identifique a propriedade** na [documentação do provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
2. **Adicione o lookup()** no módulo apropriado
3. **Teste com uma configuração simples**
4. **Documente o uso** (opcional)
5. **Commit com padrão**: `feat: add support for <propriedade>`

---

**Criado em**: Setembro 2025  
**Autor**: Homelab Laranjeira  
**Licença**: MIT