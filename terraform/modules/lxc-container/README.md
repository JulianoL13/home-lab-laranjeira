# 📦 Módulo LXC Container

Este módulo Terraform cria e gerencia containers LXC no Proxmox com configuração flexível e templates automatizados.

## 📋 Visão Geral

O módulo implementa criação direta de containers LXC:

1. **Download de Template**: Baixa template LXC automaticamente (opcional)
2. **Criação Direta**: Cria containers diretamente do template
3. **Configuração Automática**: Aplica configurações de rede, usuário e recursos

## 🎯 Características

- ✅ **Templates Automáticos**: Download e uso de templates LXC
- ✅ **Configuração Flexível**: Sistema de defaults + customizações
- ✅ **Escalabilidade**: Suporta múltiplos containers via `for_each`
- ✅ **Naming Automático**: Nomenclatura consistente com prefixos
- ✅ **Rede Automática**: Configuração IP/CIDR simplificada
- ✅ **Unprivileged**: Containers seguros por padrão
- ✅ **Auto-start**: Inicialização automática configurável

## 🚀 Uso Básico

```terraform
module "my_containers" {
  source = "../modules/lxc-container"

  # Configurações obrigatórias
  name_prefix = "homelab"
  node_name   = "proxmox-node"

  # Configurações dos containers
  container_configurations = {
    web = {
      vmid        = 2001
      ip_address  = "192.168.0.201"
      memory      = 2048
      cores       = 2
      rootfs_size = 10
    }
    
    cache = {
      vmid        = 2002
      ip_address  = "192.168.0.202"
      memory      = 1024
      cores       = 1
    }
    
    db = {
      vmid        = 2003
      ip_address  = "192.168.0.203"
      memory      = 4096
      cores       = 4
      rootfs_size = 20
      storage     = "local-lvm"  # Storage específico
    }
  }

  # Storage
  default_storage = "local"

  # Rede
  bridge  = "vmbr0"
  gateway = "192.168.0.1"
  
  # Autenticação
  password = "secure-password"
}
```

## � Configurações Extras com `extra_config`

O módulo suporta configurações avançadas através do bloco `extra_config` usando **lookup dinâmico**. Isso permite adicionar qualquer propriedade do provider Proxmox LXC sem modificar o módulo.

### Uso do `extra_config`

```terraform
module "my_containers" {
  source = "../modules/lxc-container"
  
  # ... configurações básicas ...
  
  container_configurations = {
    web_container = {
      vmid        = 2001
      ip_address  = "192.168.0.201"
      memory      = 2048
      cores       = 2
      rootfs_size = 15
      
      # Bloco de configurações extras
      extra_config = {
        # Sistema
        protection  = true
        description = "Container Web de Produção"
        tags        = ["web", "production", "nginx"]
        
        # CPU
        cpu_units   = 1024
        
        # Rede
        mac_address    = "02:00:00:00:02:01"
        vlan_id        = 100
        network_mtu    = 1500
        network_firewall = true
        
        # DNS
        dns_servers = ["8.8.8.8", "8.8.4.4"]
        dns_domain  = "homelab.local"
        
        # SSH
        ssh_keys = ["ssh-rsa AAAAB3NzaC1yc2EAA..."]
        
        # Mount points adicionais
        additional_mount_points = [
          {
            volume = "local:100"
            size   = "50G"
            path   = "/var/www"
            backup = true
          }
        ]
        
        # Interfaces de rede adicionais
        additional_networks = [
          {
            name    = "eth1"
            bridge  = "vmbr1"
            vlan_id = 200
          }
        ]
      }
    }
    
    # Container com configurações mínimas
    cache_container = {
      vmid        = 2002
      ip_address  = "192.168.0.202"
      memory      = 512
      cores       = 1
      rootfs_size = 8
      # Sem extra_config = usa todos os defaults
    }
  }
}
```

### Propriedades Disponíveis em `extra_config`

| Categoria | Propriedade | Tipo | Default | Descrição |
|-----------|-------------|------|---------|-----------|
| **Sistema** | `protection` | `bool` | `false` | Proteção contra exclusão acidental |
| | `description` | `string` | `null` | Descrição do container |
| | `tags` | `list(string)` | `[]` | Tags para organização |
| **CPU** | `cpu_units` | `number` | `null` | Unidades de CPU (weight scheduling) |
| **Rede** | `mac_address` | `string` | `null` | Endereço MAC específico |
| | `vlan_id` | `number` | `null` | ID da VLAN |
| | `network_mtu` | `number` | `null` | MTU da interface |
| | `network_rate_limit` | `number` | `null` | Limite de taxa em MB/s |
| | `network_firewall` | `bool` | `false` | Habilitar firewall |
| **DNS** | `dns_servers` | `list(string)` | `null` | Servidores DNS customizados |
| | `dns_domain` | `string` | `null` | Domínio DNS padrão |
| **SSH** | `ssh_keys` | `list(string)` | `null` | Chaves SSH públicas |
| **Avançado** | `additional_mount_points` | `list(object)` | `[]` | Lista de mount points adicionais |
| | `additional_networks` | `list(object)` | `[]` | Lista de interfaces de rede extras |

### Estrutura dos Objetos Avançados

#### `additional_mount_points`
```terraform
additional_mount_points = [
  {
    volume = "storage:size"  # Ex: "local:100" ou "nfs-storage:50"
    size   = "50G"          # Tamanho (opcional se especificado no volume)
    path   = "/data"        # Caminho de montagem no container
    backup = true           # Incluir em backups (opcional)
  }
]
```

#### `additional_networks`
```terraform
additional_networks = [
  {
    name        = "eth1"                    # Nome da interface
    bridge      = "vmbr1"                  # Bridge de rede
    enabled     = true                     # Interface habilitada (opcional)
    mac_address = "02:00:00:00:02:02"     # MAC específico (opcional)
    mtu         = 1500                     # MTU personalizado (opcional)
    vlan_id     = 200                      # VLAN ID (opcional)
    firewall    = false                    # Habilitar firewall (opcional)
  }
]
```

### Vantagens do `extra_config`

1. **✅ Organização**: Todas as configurações extras em um bloco
2. **✅ Flexibilidade**: Qualquer propriedade do provider LXC
3. **✅ Defaults Inteligentes**: Valores sensatos quando não especificado
4. **✅ Zero Overhead**: Só implementa o que você usar
5. **✅ Future-proof**: Funciona com futuras propriedades do provider

## �📝 Variáveis

### Obrigatórias

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `name_prefix` | `string` | Prefixo aplicado aos nomes dos containers |
| `node_name` | `string` | Nome do nó Proxmox onde os containers serão criados |
| `default_storage` | `string` | Storage padrão para containers |
| `bridge` | `string` | Bridge de rede para conectar os containers |
| `gateway` | `string` | Gateway padrão para configuração de rede dos containers |
| `password` | `string` | Senha do usuário root dos containers (sensitive) |

### Opcionais com Defaults

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `ensure_template` | `bool` | `true` | Se deve garantir que o template LXC existe |
| `container_configurations` | `map(object)` | `{}` | Mapa de configurações para cada container a ser criado |
| `default_memory` | `number` | `1024` | Memória padrão em MB para containers que não especificarem |
| `default_cores` | `number` | `1` | Número de cores padrão para containers que não especificarem |
| `default_rootfs_size` | `number` | `8` | Tamanho padrão do rootfs em GB para containers que não especificarem |
| `default_swap` | `number` | `256` | Swap padrão em MB para containers que não especificarem |
| `template_storage` | `string` | `"local"` | Storage onde o template LXC será baixado |
| `template_url` | `string` | `"http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"` | URL para download do template LXC |
| `template_name` | `string` | `"ubuntu-22.04-standard_22.04-1_amd64.tar.zst"` | Nome do arquivo do template LXC |
| `default_cidr` | `number` | `24` | CIDR padrão para configuração de rede |
| `unprivileged` | `bool` | `true` | Se os containers devem ser unprivileged |
| `start_on_boot` | `bool` | `true` | Se os containers devem iniciar automaticamente com o boot |
| `started` | `bool` | `true` | Se os containers devem estar iniciados após criação |
| `os_type` | `string` | `"ubuntu"` | Tipo do sistema operacional do template |
| `network_interface_name` | `string` | `"eth0"` | Nome da interface de rede do container |
| `network_interface_enabled` | `bool` | `true` | Se a interface de rede deve estar habilitada |

### Configuração de Container Individual

Cada container em `container_configurations` pode ter:

```terraform
container_configurations = {
  "container-name" = {
    vmid        = number           # Obrigatório
    ip_address  = string           # Obrigatório
    memory      = optional(number) # Usa default_memory se omitido
    cores       = optional(number) # Usa default_cores se omitido
    rootfs_size = optional(number) # Usa default_rootfs_size se omitido
    storage     = optional(string) # Usa default_storage se omitido
    swap        = optional(number) # Usa default_swap se omitido
    cidr        = optional(number) # Usa default_cidr se omitido
  }
}
```

## 📤 Outputs

| Output | Tipo | Descrição |
|--------|------|-----------|
| `containers` | `map(object)` | Informações completas dos containers criados |
| `container_ids` | `list(number)` | Lista dos IDs dos containers criados |
| `container_ips` | `map(string)` | Mapa de IPs dos containers (nome -> IP) |
| `template_downloaded` | `bool` | Se o template LXC foi baixado |

### Exemplo de Output `containers`:
```terraform
containers = {
  "web" = {
    vm_id      = 2001
    name       = "homelab-web"
    ip_address = "192.168.0.201"
    memory     = 2048
    cores      = 2
  }
  "cache" = {
    vm_id      = 2002
    name       = "homelab-cache"
    ip_address = "192.168.0.202"
    memory     = 1024
    cores      = 1
  }
}
```

## 🏗️ Arquitetura Interna

### Fluxo de Criação
```
📥 Download Template → 📦 Create Containers
```

### Recursos Criados

1. **Template Download** (`proxmox_virtual_environment_download_file`)
   - Baixa template LXC do Proxmox (condicional)
   - Armazena no `template_storage`
   - Content type: `vztmpl`

2. **LXC Containers** (`proxmox_virtual_environment_container`)
   - Containers criados diretamente do template
   - Configurações individuais por container
   - Nomes automáticos: `{name_prefix}-{container_name}`

### Processamento Local

O módulo usa `locals.processed_containers` para:
- Aplicar defaults para campos não especificados
- Calcular IP com CIDR automaticamente
- Gerar nomes consistentes
- Merge de configurações em 3 camadas: defaults → config → calculated

## 📁 Estrutura de Arquivos

```
lxc-container/
├── main.tf      # Recursos principais
├── variables.tf # Definições de variáveis
├── outputs.tf   # Outputs do módulo
├── versions.tf  # Versões do provider
└── README.md    # Esta documentação
```

## 🔧 Exemplos Avançados

### 1. Containers com Configurações Diferenciadas
```terraform
module "mixed_containers" {
  source = "../modules/lxc-container"

  name_prefix = "prod"
  node_name   = "proxmox-01"

  container_configurations = {
    # Container básico usando defaults
    cache = {
      vmid       = 3001
      ip_address = "10.0.1.201"
    }
    
    # Container customizado para aplicação
    app = {
      vmid        = 3002
      ip_address  = "10.0.1.202"
      memory      = 4096  # 4GB
      cores       = 4
      rootfs_size = 20    # 20GB
      swap        = 1024  # 1GB swap
      storage     = "ssd-pool"
    }
    
    # Container em rede diferente
    dmz_proxy = {
      vmid       = 3003
      ip_address = "192.168.100.10"
      cidr       = 28     # /28 em vez de /24
      memory     = 2048
      cores      = 2
    }
  }

  # Configurações globais
  default_storage = "hdd-pool"
  bridge          = "vmbr1"
  gateway         = "10.0.1.1"
  password        = var.container_root_password
}
```

### 2. Template Customizado
```terraform
module "custom_template_containers" {
  source = "../modules/lxc-container"

  name_prefix     = "dev"
  node_name       = "proxmox-02"
  ensure_template = true

  # Template personalizado
  template_storage = "local"
  template_url     = "http://download.proxmox.com/images/system/debian-11-standard_11.7-1_amd64.tar.zst"
  template_name    = "debian-11-standard_11.7-1_amd64.tar.zst"
  os_type          = "debian"

  container_configurations = {
    web = { vmid = 4001, ip_address = "172.16.0.101" }
    api = { vmid = 4002, ip_address = "172.16.0.102" }
  }

  default_storage = "local-lvm"
  bridge          = "vmbr0"
  gateway         = "172.16.0.1"
  password        = "debian-password"
}
```

### 3. Configuração com Parâmetros Customizados
```terraform
module "custom_containers" {
  source = "../modules/lxc-container"

  name_prefix = "test"
  node_name   = "proxmox-03"

  # Comportamento personalizado
  unprivileged              = false  # Privileged containers
  start_on_boot            = false  # Não iniciar no boot
  started                  = false  # Não iniciar após criação
  network_interface_name   = "eth1"  # Interface alternativa
  network_interface_enabled = true
  default_cidr             = 16     # Rede /16

  container_configurations = {
    experiment = {
      vmid       = 5001
      ip_address = "10.10.0.101"
      memory     = 512
      cores      = 1
      rootfs_size = 5
      swap       = 0  # Sem swap
    }
  }

  default_storage = "local"
  bridge          = "vmbr2"
  gateway         = "10.10.0.1"
  password        = "test-password"
}
```

### 4. Múltiplos Containers de Produção
```terraform
module "production_containers" {
  source = "../modules/lxc-container"

  name_prefix = "prod"
  node_name   = "proxmox-cluster"

  container_configurations = {
    # Frontend
    nginx = {
      vmid        = 6001
      ip_address  = "10.0.2.10"
      memory      = 1024
      cores       = 2
      rootfs_size = 10
    }
    
    # Backend API
    api = {
      vmid        = 6002
      ip_address  = "10.0.2.11"
      memory      = 2048
      cores       = 2
      rootfs_size = 15
    }
    
    # Cache
    redis = {
      vmid        = 6003
      ip_address  = "10.0.2.12"
      memory      = 1024
      cores       = 1
      rootfs_size = 8
      swap        = 512
    }
    
    # Database
    postgres = {
      vmid        = 6004
      ip_address  = "10.0.2.13"
      memory      = 4096
      cores       = 4
      rootfs_size = 50
      storage     = "ssd-storage"
      swap        = 2048
    }
    
    # Monitoring
    grafana = {
      vmid        = 6005
      ip_address  = "10.0.2.14"
      memory      = 2048
      cores       = 2
      rootfs_size = 20
    }
  }

  # Configurações globais
  default_storage = "hdd-storage"
  bridge          = "vmbr0"
  gateway         = "10.0.2.1"
  password        = var.production_password
  
  # Template Ubuntu LTS
  template_url  = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  template_name = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **Erro de Storage**
   ```
   Error: storage 'X' does not support content type 'vztmpl'
   ```
   **Solução**: Usar storage compatível com templates LXC para `template_storage`

2. **Template não encontrado**
   ```
   Error: template file not found
   ```
   **Solução**: Verificar se `ensure_template = true` ou template já existe no storage

3. **IP duplicado**
   ```
   Error: IP address already in use
   ```
   **Solução**: Verificar IPs únicos em `container_configurations`

4. **Container não inicia**
   ```
   Error: container failed to start
   ```
   **Solução**: Verificar recursos disponíveis (memória, cores) no node

### Debug

Para debug, use os outputs:
```terraform
# Verificar containers criados
output "debug_containers" {
  value = module.my_containers.containers
}

# Verificar IPs atribuídos
output "debug_ips" {
  value = module.my_containers.container_ips
}

# Verificar se template foi baixado
output "debug_template" {
  value = module.my_containers.template_downloaded
}
```

### Logs de Container

Para verificar logs de um container:
```bash
# No Proxmox node
pct list                    # Listar containers
pct config 2001            # Ver configuração
pct start 2001             # Iniciar container
pct enter 2001             # Entrar no container
```

## 🔧 Manutenção

### Atualização de Templates

Para atualizar templates:
1. Definir nova `template_url` e `template_name`
2. Executar `terraform apply`
3. Recriar containers (ou usar nova configuração)

### Backup e Restore

```bash
# Backup de container
vzdump 2001 --storage local

# Restore de container  
pct restore 2001 /var/lib/vz/dump/vzdump-lxc-2001-*.tar.lz4
```

## 📊 Monitoramento

### Recursos Típicos por Tipo

| Tipo | Memory | Cores | Disk | Uso |
|------|--------|-------|------|-----|
| **Proxy/Web** | 1-2GB | 1-2 | 8-15GB | Nginx, Apache |
| **API/App** | 2-4GB | 2-4 | 10-20GB | Node.js, Python |
| **Cache** | 1-2GB | 1-2 | 5-10GB | Redis, Memcached |
| **Database** | 4-8GB | 2-4 | 20-100GB | PostgreSQL, MySQL |
| **Monitoring** | 1-3GB | 1-2 | 10-30GB | Grafana, Prometheus |

### Comandos Úteis

```bash
# Status dos containers
pct list
pct status <vmid>

# Recursos utilizados
pct exec <vmid> -- top
pct exec <vmid> -- df -h
pct exec <vmid> -- free -h

# Rede
pct exec <vmid> -- ip addr show
pct exec <vmid> -- ping gateway
```

## 🔗 Dependências

- **Provider**: `bpg/proxmox` >= 0.83
- **Terraform**: >= 1.5.0
- **Proxmox**: >= 7.0
- **Templates**: LXC templates compatíveis (.tar.zst)

## 📚 Referências

- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)
- [LXC Templates](https://us.lxd.images.canonical.com/)
- [Proxmox Container Templates](http://download.proxmox.com/images/system/)