# Terraform Proxmox Homelab

Este projeto Terraform utiliza o provider **BPG Proxmox** para criar e gerenciar VMs e containers LXC no Proxmox VE de forma simples e maleável, com configurações **completamente variabilizadas** e **cloud-init avançado**.

## 🚀 Características

- **Provider BPG Proxmox** versão 0.83.2+
- **Estrutura 100% variabilizada** - nada hardcoded!
- **Cloud-Init completo** com configurações YAML personalizadas
- **Configuração declarativa** usando `locals` e `for_each`
- **Templates automáticos** para VMs e containers
- **Exemplos prontos** para cluster K3s
- **Outputs detalhados** incluindo inventário Ansible
- **Configuração de segurança** automática

## 📁 Estrutura do Projeto

```
terraform/
├── terraform.tf                  # Provider e versões
├── variables.tf                  # Variáveis (100% configurável)
├── locals.tf                    # Configurações locais (VMs e containers)
├── main.tf                      # Recursos principais (totalmente variabilizado)
├── outputs.tf                   # Saídas e informações
├── terraform.tfvars.example     # Exemplo de configuração completo
├── README.md                    # Este arquivo
└── cloud-init/                 # 🆕 Configurações Cloud-Init
    ├── user-data.yaml           # Configuração principal (usuários, pacotes, scripts)
    ├── meta-data.yaml           # Metadados da instância
    ├── network-config.yaml      # Configuração avançada de rede
    ├── vendor-data.yaml         # Dados específicos do Proxmox
    └── README.md                # Documentação do Cloud-Init
```

## ⚙️ Configuração

### 1. Pré-requisitos

- Proxmox VE 7.0+ configurado
- Token de API criado no Proxmox
- Terraform 1.6.0+ instalado
- Chave SSH pública

### 2. Configuração das Variáveis

Copie o arquivo de exemplo e ajuste as configurações:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite o `terraform.tfvars` com suas configurações **obrigatórias**:

```hcl
# OBRIGATÓRIAS
proxmox_api_url      = "https://SEU-PROXMOX:8006/api2/json"
proxmox_api_token    = "SEU-TOKEN@pam!NOME-TOKEN"
proxmox_insecure_tls = true
ssh_username         = "root"
ssh_public_key       = "ssh-rsa AAAAB3... sua-chave-publica"
default_node_name    = "pve01"
storage_name         = "local-lvm"
bridge_name          = "vmbr0"

# OPCIONAIS (usar padrões se não especificado)
vm_cpu_type               = "x86-64-v2-AES"
vm_bios_type             = "seabios"
container_unprivileged   = true
cloudinit_enable_user_data = true
# ... veja terraform.tfvars.example para todas as opções
```

## 🎯 Cloud-Init Avançado

### 🔧 Configuração Automática Inclusa

O **user-data.yaml** configura automaticamente:

- **👤 Usuários**: `admin` (sudo) e `service` (apps)
- **📦 Pacotes**: Docker, Git, Vim, Node Exporter, QEMU Agent
- **🔐 SSH**: Configuração segura com chaves públicas
- **🛡️ Firewall**: UFW configurado automaticamente
- **🐳 Docker**: Instalado e configurado
- **📊 Monitoramento**: Node Exporter na porta 9100
- **⚡ Performance**: Otimizações de kernel
- **🎨 Interface**: MOTD personalizado e aliases úteis

### 🔑 Credenciais Padrão

- **Usuário**: `admin`
- **Senha padrão**: `changeMe123!` ⚠️ **ALTERE IMEDIATAMENTE!**
- **SSH**: Configurado com sua chave pública

### 📂 Estrutura Cloud-Init

```
cloud-init/
├── user-data.yaml       # 🎯 Configuração principal
├── meta-data.yaml       # 🏷️ Metadados da instância  
├── network-config.yaml  # 🌐 Configuração de rede
├── vendor-data.yaml     # 🏢 Dados do Proxmox
└── README.md           # 📚 Documentação completa
```

## 🚀 Uso

### Inicialização

```bash
# Inicializar o Terraform
terraform init

# Verificar o plano
terraform plan

# Aplicar as mudanças
terraform apply
```

### Acesso Rápido SSH

```bash
# Ver comandos SSH prontos
terraform output vm_ssh_commands
terraform output container_ssh_commands

# Exemplo de output:
# k3s-master-01 = "ssh admin@192.168.50.11"
```

### Personalização das Máquinas

Edite o arquivo `locals.tf` para definir suas VMs e containers:

```hcl
locals {
  vm_configs = {
    "minha-vm-01" = {
      vmid        = 101
      node_name   = var.default_node_name
      cores       = 2
      memory      = 4096
      disk_size   = 30
      ip_address  = "192.168.1.10/24"
      gateway     = "192.168.1.1"
      vlan_id     = null  # ou número da VLAN
      template    = var.vm_template_name
      ciuser      = "admin"  # usuário criado pelo cloud-init
      tags        = ["web", "terraform"]
    }
    # Adicione mais VMs conforme necessário
  }

  container_configs = {
    "meu-container-01" = {
      vmid        = 201
      node_name   = var.default_node_name
      cores       = 1
      memory      = 1024
      disk_size   = 10
      ip_address  = "192.168.1.20/24"
      gateway     = "192.168.1.1"
      vlan_id     = null
      template    = var.container_template_name
      hostname    = "meu-container-01"
      tags        = ["database", "terraform"]
    }
    # Adicione mais containers conforme necessário
  }
}
```

## 🔧 Variabilização Completa

**Tudo é configurável via variáveis!** Exemplos:

```hcl
# CPU e Performance
vm_cpu_type         = "x86-64-v2-AES"
vm_disk_cache       = "writeback"
vm_disk_iothread    = true

# Comportamento
vm_started          = true
vm_on_boot          = true
container_unprivileged = true

# Cloud-Init
cloudinit_enable_user_data = true
cloudinit_dns_servers      = ["1.1.1.1", "8.8.8.8"]

# Imagens customizadas
vm_image_url = "https://minha-imagem-customizada.qcow2"
```

## 📝 Exemplos de Configuração

### Cluster K3s (Já incluído)

O projeto já vem com exemplos de VMs para um cluster K3s:
- `k3s-master-01`: Master node (VMID 101)
- `k3s-worker-01`: Worker node (VMID 102)
- `k3s-worker-02`: Worker node (VMID 103)

### Containers de Serviços

- `monitoring-01`: Para Prometheus/Grafana (VMID 201)
- `database-01`: Para PostgreSQL (VMID 202)

## 🔧 Customização

### Adicionando Novas VMs

1. Edite `locals.tf`
2. Adicione nova entrada em `vm_configs`
3. Execute `terraform plan` e `terraform apply`

### Adicionando Novos Containers

1. Edite `locals.tf`
2. Adicione nova entrada em `container_configs`
3. Execute `terraform plan` e `terraform apply`

### Modificando Templates

Ajuste as variáveis no `terraform.tfvars`:

```hcl
vm_template_name        = "ubuntu-22.04-cloudinit"
container_template_name = "ubuntu-22.04-standard"
```

## 🔄 Templates Automáticos

O Terraform automaticamente:

1. **Faz download** dos templates Debian 12 para VMs e containers
2. **Cria as VMs** baseadas no template baixado
3. **Configura cloud-init** com usuário e SSH
4. **Cria containers LXC** com configurações básicas

## 🏷️ Sistema de Tags

Use tags para organizar e categorizar recursos:

```hcl
tags = ["k3s", "master", "production", "terraform"]
```

Tags úteis para automação:
- `k3s`, `master`, `worker` - Para clusters Kubernetes
- `web`, `database`, `monitoring` - Por função
- `production`, `staging`, `development` - Por ambiente
- `terraform` - Para identificar recursos gerenciados

## 🔗 Integração com Ansible

O output `ansible_inventory` gera automaticamente um inventário pronto para uso:

```bash
# Salvar inventário em arquivo
terraform output -json ansible_inventory > inventory.json

# Usar com ansible-playbook
ansible-playbook -i inventory.json playbook.yml
```

## 🛠️ Solução de Problemas

### Erro de Certificado TLS

```hcl
proxmox_insecure_tls = true
```

### Erro de Autenticação

Verifique se o token de API tem as permissões necessárias no Proxmox.

### Storage não encontrado

Ajuste `storage_name` para um storage disponível no seu ambiente:

```bash
# No Proxmox, verificar storages disponíveis
pvesm status
```

## 📚 Documentação Adicional

- [Provider BPG Proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Terraform Documentation](https://www.terraform.io/docs)

## 🤝 Contribuição

Sinta-se à vontade para sugerir melhorias e modificações para tornar este projeto ainda mais útil!