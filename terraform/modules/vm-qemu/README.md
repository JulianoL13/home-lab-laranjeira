# 🖥️ Módulo VM QEMU

Este módulo Terraform cria e gerencia máquinas virtuais (VMs) no Proxmox usando templates Cloud-Init para eficiência e padronização.

## 📋 Visão Geral

O módulo implementa um sistema avançado de criação de VMs baseado em templates:

1. **Download de Imagem Cloud**: Baixa imagem Ubuntu Cloud automaticamente
2. **Criação de Template**: Cria template base com Cloud-Init
3. **Clonagem de VMs**: Clona VMs personalizadas a partir do template

## 🎯 Características

- ✅ **Sistema de Templates**: Criação eficiente via clonagem
- ✅ **Cloud-Init**: Configuração automática de usuários e SSH
- ✅ **Configuração Flexível**: Sistema de defaults + customizações
- ✅ **Escalabilidade**: Suporta múltiplas VMs via `for_each`
- ✅ **Naming Automático**: Nomenclatura consistente com prefixos
- ✅ **Rede Automática**: Configuração IP/CIDR simplificada

## 🚀 Uso Básico

```terraform
module "my_vms" {
  source = "../modules/vm-qemu"

  # Configurações obrigatórias
  base_vmid   = 1000
  name_prefix = "homelab"
  node_name   = "proxmox-node"

  # Configurações das VMs
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
      memory     = 8192
      cores      = 4
    }
  }

  # Storages
  default_storage                = "Machines"
  default_snippet_storage        = "local"
  default_initialization_storage = "local"

  # Rede
  bridge  = "vmbr0"
  gateway = "192.168.0.1"

  # Autenticação
  user    = "ubuntu"
  ssh_key = "ssh-rsa AAAAB3..."

  # Imagem
  image_url  = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  image_name = "ubuntu-22.04-cloudimg-amd64.img"
}
```

## � Configurações Extras com `extra_config`

O módulo suporta configurações avançadas através do bloco `extra_config` usando **lookup dinâmico**. Isso permite adicionar qualquer propriedade do provider Proxmox sem modificar o módulo.

### Uso do `extra_config`

```terraform
module "my_vms" {
  source = "../modules/vm-qemu"
  
  # ... configurações básicas ...
  
  vm_configurations = {
    web_server = {
      vmid       = 1001
      ip_address = "192.168.0.101"
      memory     = 4096
      cores      = 2
      disk_size  = 50
      
      # Bloco de configurações extras
      extra_config = {
        # Sistema
        protection      = true
        bios           = "ovmf"
        machine        = "q35"
        description    = "Servidor Web de Produção"
        tags           = ["web", "production", "nginx"]
        
        # CPU
        cpu_sockets    = 2
        cpu_flags      = ["+aes"]
        
        # Memória
        memory_shared  = 1024
        
        # Disco
        disk_cache     = "none"
        disk_ssd       = true
        disk_iothread  = true
        disk_discard   = true
        
        # Rede
        mac_address    = "02:00:00:00:01:01"
        vlan_id        = 100
        network_mtu    = 1500
        network_firewall = true
        
        # Recursos extras
        additional_disks = [
          {
            datastore_id = "fast-ssd"
            size         = 100
            interface    = "scsi1"
            cache        = "none"
            ssd          = true
          }
        ]
        
        additional_networks = [
          {
            bridge      = "vmbr1"
            vlan_id     = 200
            mac_address = "02:00:00:00:01:02"
          }
        ]
      }
    }
    
    # VM com configurações mínimas (sem extra_config)
    cache_server = {
      vmid       = 1002
      ip_address = "192.168.0.102"
      memory     = 1024
      cores      = 1
      disk_size  = 20
      # Sem extra_config = usa todos os defaults
    }
  }
}
```

### Propriedades Disponíveis em `extra_config`

| Categoria | Propriedade | Tipo | Default | Descrição |
|-----------|-------------|------|---------|-----------|
| **Sistema** | `protection` | `bool` | `false` | Proteção contra exclusão acidental |
| | `bios` | `string` | `"seabios"` | Tipo de BIOS (`"seabios"` ou `"ovmf"`) |
| | `machine` | `string` | `"pc"` | Tipo de máquina (`"pc"` ou `"q35"`) |
| | `description` | `string` | `null` | Descrição da VM |
| | `keyboard_layout` | `string` | `null` | Layout do teclado |
| | `tags` | `list(string)` | `[]` | Tags para organização |
| **CPU** | `cpu_sockets` | `number` | `1` | Número de sockets de CPU |
| | `cpu_flags` | `list(string)` | `null` | Flags específicas de CPU |
| | `cpu_architecture` | `string` | `null` | Arquitetura da CPU |
| **Memória** | `memory_floating` | `number` | `null` | Memória flutuante |
| | `memory_shared` | `number` | `null` | Memória compartilhada |
| **Disco** | `disk_cache` | `string` | `"writethrough"` | Modo de cache (`"none"`, `"writethrough"`, `"writeback"`) |
| | `disk_ssd` | `bool` | `false` | Marcar disco como SSD |
| | `disk_iothread` | `bool` | `false` | Usar IOThread para performance |
| | `disk_discard` | `bool` | `false` | Habilitar discard/trim |
| | `disk_backup` | `bool` | `true` | Incluir em backups |
| | `disk_replicate` | `bool` | `true` | Habilitar replicação |
| **Rede** | `mac_address` | `string` | `null` | Endereço MAC específico |
| | `vlan_id` | `number` | `null` | ID da VLAN |
| | `network_mtu` | `number` | `null` | MTU da interface |
| | `network_rate_limit` | `number` | `null` | Limite de taxa em MB/s |
| | `network_firewall` | `bool` | `false` | Habilitar firewall |
| **Avançado** | `additional_disks` | `list(object)` | `[]` | Lista de discos adicionais |
| | `additional_networks` | `list(object)` | `[]` | Lista de interfaces de rede extras |

### Vantagens do `extra_config`

1. **✅ Flexibilidade Total**: Qualquer propriedade do provider Proxmox
2. **✅ Zero Overhead**: Só implementa o que você usar
3. **✅ Organização**: Todas as configurações extras em um bloco
4. **✅ Defaults Inteligentes**: Valores sensatos quando não especificado
5. **✅ Future-proof**: Funciona com futuras propriedades do provider

## �📝 Variáveis

### Obrigatórias

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `base_vmid` | `number` | VM ID base usado para o template |
| `name_prefix` | `string` | Prefixo aplicado aos nomes das VMs e template |
| `node_name` | `string` | Nome do nó Proxmox onde os recursos serão criados |
| `default_storage` | `string` | Storage padrão para discos das VMs |
| `default_snippet_storage` | `string` | Storage padrão para arquivos cloud-config |
| `default_initialization_storage` | `string` | Storage padrão para arquivos de inicialização |
| `bridge` | `string` | Bridge de rede para conectar as VMs |
| `gateway` | `string` | Gateway padrão para configuração de rede das VMs |
| `user` | `string` | Nome do usuário criado nas VMs via cloud-init |
| `ssh_key` | `string` | Chave SSH pública adicionada ao usuário das VMs |
| `image_url` | `string` | URL para download da imagem base do template |
| `image_name` | `string` | Nome do arquivo da imagem após download |

### Opcionais com Defaults

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `create_template` | `bool` | `true` | Se deve criar template base e arquivos relacionados |
| `vm_configurations` | `map(object)` | `{}` | Mapa de configurações para cada VM a ser criada |
| `default_memory` | `number` | `2048` | Memória padrão em MB para VMs que não especificarem |
| `default_cores` | `number` | `2` | Número de cores padrão para VMs que não especificarem |
| `default_disk_size` | `number` | `25` | Tamanho padrão do disco em GB para VMs que não especificarem |
| `image_sha256` | `string` | `""` | Hash SHA256 da imagem para verificação (vazio para pular) |
| `default_cidr` | `number` | `24` | CIDR padrão para configuração de rede |
| `cpu_type` | `string` | `"host"` | Tipo de CPU para as VMs |
| `disk_interface` | `string` | `"scsi0"` | Interface do disco para as VMs |
| `scsi_hardware` | `string` | `"virtio-scsi-pci"` | Hardware SCSI para as VMs |
| `network_model` | `string` | `"virtio"` | Modelo da interface de rede |
| `agent_enabled` | `bool` | `true` | Se o agente QEMU deve ser habilitado |
| `on_boot` | `bool` | `true` | Se as VMs devem iniciar automaticamente com o boot |
| `started` | `bool` | `true` | Se as VMs devem estar iniciadas após criação |

### Configuração de VM Individual

Cada VM em `vm_configurations` pode ter:

```terraform
vm_configurations = {
  "vm-name" = {
    vmid                   = number           # Obrigatório
    ip_address             = string           # Obrigatório
    memory                 = optional(number) # Usa default_memory se omitido
    cores                  = optional(number) # Usa default_cores se omitido
    disk_size              = optional(number) # Usa default_disk_size se omitido
    storage                = optional(string) # Usa default_storage se omitido
    snippet_storage        = optional(string) # Usa default_snippet_storage se omitido
    initialization_storage = optional(string) # Usa default_initialization_storage se omitido
    cidr                   = optional(number) # Usa default_cidr se omitido
  }
}
```

## 📤 Outputs

| Output | Tipo | Descrição |
|--------|------|-----------|
| `template_id` | `number` | VM ID do template criado |
| `template_name` | `string` | Nome do template criado |
| `vms` | `map(object)` | Informações completas das VMs criadas |
| `vm_ids` | `list(number)` | Lista dos IDs das VMs criadas |
| `vm_ips` | `map(string)` | Mapa de IPs das VMs (nome -> IP) |

### Exemplo de Output `vms`:
```terraform
vms = {
  "web" = {
    vm_id      = 2001
    name       = "homelab-web"
    ip_address = "192.168.0.101"
    memory     = 4096
    cores      = 2
  }
  "db" = {
    vm_id      = 2002
    name       = "homelab-db"
    ip_address = "192.168.0.102"
    memory     = 8192
    cores      = 4
  }
}
```

## 🏗️ Arquitetura Interna

### Fluxo de Criação
```
📥 Download Image → 🎯 Create Template → 🖥️ Clone VMs
```

### Recursos Criados

1. **Template Download** (`proxmox_virtual_environment_download_file`)
   - Baixa imagem Cloud do Ubuntu
   - Armazena no `default_snippet_storage`

2. **Cloud-Config File** (`proxmox_virtual_environment_file`)
   - Gera arquivo `user-data.yml` personalizado
   - Configura usuário, SSH e hostname

3. **Template VM** (`proxmox_virtual_environment_vm`)
   - VM base marcada como template
   - VMID = `base_vmid`
   - Nome = `{name_prefix}-template`

4. **Production VMs** (`proxmox_virtual_environment_vm`)
   - VMs clonadas do template
   - Configurações personalizadas por VM
   - Nomes automáticos: `{name_prefix}-{vm_name}`

### Gerenciamento de Templates

O módulo suporta dois modos de operação para templates:

#### **Modo 1: Template Gerenciado (`create_template = true`)**
```terraform
create_template = true  # Padrão
base_vmid       = 1000

# O que acontece:
# 1. Baixa imagem Cloud (se não existir)
# 2. Cria template com VMID 1000
# 3. Clona VMs a partir do template 1000
```

**Lógica interna:**
```terraform
clone {
  vm_id = proxmox_virtual_environment_vm.template[0].vm_id  # VMID do template criado
}
```

#### **Modo 2: Template Externo (`create_template = false`)**
```terraform
create_template = false
base_vmid       = 2000

# O que acontece:
# 1. Assume que já existe template com VMID 2000
# 2. Clona VMs diretamente do template 2000 existente
# 3. Não cria nem gerencia o template
```

**Lógica interna:**
```terraform
clone {
  vm_id = local.template_vmid  # = var.base_vmid (2000)
}
```

#### **Casos de Uso:**

**Template Gerenciado** - Use quando:
- ✅ Quer controle total sobre o template
- ✅ Quer padronizar imagens Cloud específicas
- ✅ Primeira vez criando infraestrutura

**Template Externo** - Use quando:
- ✅ Já tem template customizado no Proxmox
- ✅ Template foi criado manualmente ou por outro processo
- ✅ Quer reutilizar template entre múltiplos módulos

### Processamento Local

O módulo usa `locals.processed_vms` para:
- Aplicar defaults para campos não especificados
- Calcular IP com CIDR automaticamente
- Gerar nomes consistentes
- Merge de configurações em 3 camadas: defaults → config → calculated

## 📁 Estrutura de Arquivos

```
vm-qemu/
├── main.tf           # Recursos principais
├── variables.tf      # Definições de variáveis
├── outputs.tf        # Outputs do módulo
├── versions.tf       # Versões do provider
├── templates/
│   └── user-data.tpl # Template Cloud-Init
└── README.md         # Esta documentação
```

## 🔧 Exemplos Avançados

### 1. VMs com Configurações Diferenciadas
```terraform
module "mixed_vms" {
  source = "../modules/vm-qemu"

  base_vmid   = 2000
  name_prefix = "prod"
  node_name   = "proxmox-01"

  vm_configurations = {
    # VM básica usando defaults
    cache = {
      vmid       = 2001
      ip_address = "10.0.1.101"
    }
    
    # VM customizada para banco
    database = {
      vmid       = 2002
      ip_address = "10.0.1.102"
      memory     = 16384  # 16GB
      cores      = 8
      disk_size  = 200    # 200GB
      storage    = "ssd-pool"
    }
    
    # VM em rede diferente
    dmz_web = {
      vmid       = 2003
      ip_address = "192.168.100.10"
      cidr       = 28     # /28 em vez de /24
    }
  }

  # Configurações globais
  default_storage                = "hdd-pool"
  default_snippet_storage        = "local"
  default_initialization_storage = "local"
  bridge                         = "vmbr1"
  gateway                        = "10.0.1.1"
  
  # Cloud image customizada
  image_url  = "https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img"
  image_name = "ubuntu-20.04-cloudimg-amd64.img"
  
  user    = "admin"
  ssh_key = file("~/.ssh/id_rsa.pub")
}
```

### 2. Ambiente com Template Externo
```terraform
module "existing_template_vms" {
  source = "../modules/vm-qemu"

  base_vmid       = 3000
  name_prefix     = "dev"
  node_name       = "proxmox-02"
  create_template = false  # Usa template existente

  vm_configurations = {
    app1 = { vmid = 3001, ip_address = "172.16.0.101" }
    app2 = { vmid = 3002, ip_address = "172.16.0.102" }
  }

  default_storage                = "local-lvm"
  default_snippet_storage        = "local"
  default_initialization_storage = "local"
  bridge                         = "vmbr0"
  gateway                        = "172.16.0.1"
  user                           = "ubuntu"
  ssh_key                        = var.ssh_public_key

  # Não usado quando create_template = false
  image_url  = ""
  image_name = ""
}
```

**Como o módulo diferencia os templates:**

Quando `create_template = false`, o módulo usa um template **já existente** no Proxmox baseado no `base_vmid`:

```terraform
# Em main.tf - linha que faz a clonagem
clone {
  vm_id = var.create_template ? proxmox_virtual_environment_vm.template[0].vm_id : local.template_vmid
}

# onde local.template_vmid = var.base_vmid
```

**Cenários:**

1. **`create_template = true` (padrão)**:
   - Cria novo template com VMID = `base_vmid` (3000)
   - Clona VMs a partir deste template recém-criado
   - Template é gerenciado pelo Terraform

2. **`create_template = false`**:
   - **Assume** que já existe um template com VMID = `base_vmid` (3000)
   - Clona VMs diretamente deste template existente
   - Template **não é gerenciado** pelo Terraform

**Pré-requisito importante**: Para usar `create_template = false`, você **deve** ter um template existente no Proxmox com o VMID igual ao `base_vmid` especificado.
```

### 3. Configuração com Hardware Personalizado
```terraform
module "performance_vms" {
  source = "../modules/vm-qemu"

  # ... configurações básicas ...

  # Hardware personalizado
  cpu_type         = "kvm64"           # CPU específica
  disk_interface   = "virtio0"         # Virtio em vez de SCSI
  scsi_hardware    = "virtio-scsi-single"
  network_model    = "e1000"           # E1000 para compatibilidade
  agent_enabled    = false             # Sem QEMU agent
  on_boot          = false             # Não iniciar no boot
  started          = false             # Não iniciar após criação
  default_cidr     = 16                # Rede /16

  vm_configurations = {
    high_perf = {
      vmid       = 4001
      ip_address = "10.10.0.101"
      memory     = 32768  # 32GB
      cores      = 16
      disk_size  = 500
    }
  }
}
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **Erro de Storage**
   ```
   Error: storage 'X' does not support content type 'iso'
   ```
   **Solução**: Usar storage compatível com ISOs para `default_snippet_storage`

2. **Template já existe**
   ```
   Error: VM with ID X already exists
   ```
   **Solução**: Usar `base_vmid` diferente ou remover template existente

3. **IP duplicado**
   ```
   Error: IP address already in use
   ```
   **Solução**: Verificar IPs únicos em `vm_configurations`

### Debug

Para debug, use os outputs:
```terraform
# Verificar configurações processadas
output "debug_processed_vms" {
  value = module.my_vms.vms
}

# Verificar template criado
output "debug_template" {
  value = {
    id   = module.my_vms.template_id
    name = module.my_vms.template_name
  }
}
```

## 🔗 Dependências

- **Provider**: `bpg/proxmox` >= 0.83
- **Terraform**: >= 1.5.0
- **Proxmox**: >= 7.0
- **Template**: Ubuntu Cloud Images (ou compatível)

## 📚 Referências

- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
- [Cloud-Init Documentation](https://cloud-init.readthedocs.io/)