# 🏠 Homelab Infrastructure with Terraform

Este projeto utiliza Terraform para gerenciar infraestrutura de homelab no Proxmox, criando VMs e containers LXC de forma organizada e reutilizável.

## 📋 Pré-requisitos

- **Proxmox VE** 7.0+ configurado e funcionando
- **Terraform** 1.5.0+ instalado
- Acesso via **API token** ou usuário/senha ao Proxmox
- **Storage "Machines"** configurado no Proxmox (ou ajustar variável)

## 🚀 Quick Start

### 1. Clonar e Configurar

```bash
cd terraform/homelab
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com suas configurações
```

### 2. Configurar Variáveis

```hcl
# terraform.tfvars
pm_api_url      = "https://192.168.1.100:8006/api2/json"
pm_user         = "root@pam"  
pm_password     = "sua_senha"  # OU usar API token (recomendado)
node_name       = "seu-node"
ssh_public_key  = "ssh-ed25519 AAAAB... sua-chave"
lxc_password    = "senha-containers"
```

### 3. Executar

```bash
terraform init
terraform plan
terraform apply
```

## 📊 O que será criado

### 🖥️ **VMs Ubuntu 22.04**
- **homelab-web**: 4GB RAM, 2 cores, 50GB disk (192.168.0.101)
- **homelab-db**: 2GB RAM, 1 core, 30GB disk (192.168.0.102)  
- **homelab-cache**: 1GB RAM, 1 core, 20GB disk (192.168.0.103)

### 📦 **Containers LXC Ubuntu**
- **homelab-web**: 2GB RAM, 2 cores, 10GB disk (192.168.0.201)
- **homelab-db**: 4GB RAM, 4 cores, 20GB disk (192.168.0.202)
- **homelab-cache**: 512MB RAM, 1 core, 5GB disk (192.168.0.203)

## 🔧 Configuração Personalizada

### Modificar VMs/Containers

Edite as configurações em `homelab/main.tf`:

```hcl
# Adicionar nova VM
vm_configurations = {
  web = { vmid = 1001, ip_address = "192.168.0.101", memory = 4096, cores = 2, disk_size = 50 }
  db  = { vmid = 1002, ip_address = "192.168.0.102", memory = 2048, cores = 1, disk_size = 30 }
  # Nova VM
  monitoring = { vmid = 1004, ip_address = "192.168.0.104", memory = 2048, cores = 2, disk_size = 25 }
}
```

### Usar API Token (Recomendado)

```hcl
# terraform.tfvars
pm_api_token_id     = "root@pam!terraform"
pm_api_token_secret = "seu-token-secreto"
# pm_user e pm_password podem ser omitidos
```

## 📤 Outputs Disponíveis

Após `terraform apply`, você verá:

```bash
# IPs para conexão rápida
vm_ips = {
  "cache" = "192.168.0.103"
  "db" = "192.168.0.102"  
  "web" = "192.168.0.101"
}

# Comandos SSH prontos
ssh_connection_commands = {
  "web" = "ssh ubuntu@192.168.0.101"
  "db" = "ssh ubuntu@192.168.0.102"
  "cache" = "ssh ubuntu@192.168.0.103"
}
```

## 🏗️ Arquitetura do Projeto

```
terraform/
├── homelab/                    # Configuração principal
│   ├── main.tf                # Recursos e módulos
│   ├── variables.tf           # Variáveis de entrada
│   ├── outputs.tf             # Outputs úteis
│   ├── versions.tf            # Versões e providers
│   └── terraform.tfvars       # Seus valores (não commitado)
├── modules/
│   ├── common/                # Lógica compartilhada
│   ├── vm-qemu/              # Módulo para VMs
│   └── lxc-container/        # Módulo para containers
└── state/                     # Estado do Terraform
```

## 🔒 Segurança

### ⚠️ **IMPORTANTE: Não commitar senhas**

```bash
# Adicione ao .gitignore
echo "terraform.tfvars" >> .gitignore
echo "*.tfstate*" >> .gitignore  
```

### Usar Variáveis de Ambiente

```bash
export TF_VAR_pm_password="sua_senha"
export TF_VAR_lxc_password="senha_containers"
# Remover do terraform.tfvars
```

## 🧹 Limpeza

```bash
# Destruir toda infraestrutura
terraform destroy

# Limpar state local
rm -rf .terraform/
rm terraform.tfstate*
```

## 🎯 Próximos Passos

1. **Configurar DNS**: Adicionar entradas para os IPs
2. **Ansible**: Configurar provisionamento com Ansible
3. **Monitoring**: Adicionar Prometheus/Grafana
4. **Backup**: Configurar snapshots automáticos

## 🐛 Troubleshooting

### Erro de Autenticação
```bash
# Verificar conectividade
curl -k https://192.168.1.100:8006/api2/json/access/ticket

# Testar token
export PVE_API_TOKEN_ID="root@pam!terraform"
export PVE_API_TOKEN_SECRET="seu-token"
```

### Storage não encontrado
```bash
# Listar storages disponíveis
pvesm status
```

### Conflito de VMID
```bash
# Listar VMs existentes
qm list
pct list
```

## 📚 Referências

- [Proxmox VE API](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- [Terraform Proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest)
- [Cloud-init Ubuntu](https://cloud-init.io/)

---
**🎉 Projeto otimizado com boas práticas do Terraform!**