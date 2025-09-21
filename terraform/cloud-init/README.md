# Cloud-Init Configuration Files

Esta pasta contém os arquivos de configuração do Cloud-Init para as VMs do homelab.

## 📁 Arquivos

### `user-data.yaml`
**Configuração principal do Cloud-Init**
- 👤 Criação de usuários (admin, service)
- 📦 Instalação de pacotes essenciais
- 🐳 Configuração do Docker
- 🔧 Scripts e aliases úteis
- 🛡️ Configuração de segurança
- 📊 Node Exporter para monitoramento
- 🚀 MOTD personalizado

### `meta-data.yaml`
**Metadados da instância**
- 🏷️ Identificação da VM
- 🔑 Chaves SSH públicas
- 📍 Informações de localização
- 🏗️ Tags do homelab

### `network-config.yaml`
**Configuração avançada de rede**
- 🌐 IP estático
- 🛣️ Gateway e DNS
- 🏷️ Configuração de VLAN (opcional)
- 🔗 Bonds e rotas avançadas

### `vendor-data.yaml`
**Dados específicos do Proxmox**
- 🏢 Informações do vendor
- 📝 Logs específicos
- 🔧 Configurações do Proxmox

## 🔧 Como Usar

Os arquivos são automaticamente processados pelo Terraform usando templates. As variáveis são substituídas dinamicamente:

```hcl
# Exemplo de variáveis substituídas:
${ssh_public_key}    # Chave SSH pública
${hostname}          # Nome do host
${ip_address}        # Endereço IP
${gateway}           # Gateway de rede
${vmid}              # ID da VM no Proxmox
```

## 🛠️ Personalização

### Modificar Pacotes Instalados
Edite a seção `packages` no `user-data.yaml`:

```yaml
packages:
  - seu-pacote-aqui
  - outro-pacote
```

### Adicionar Usuários
Edite a seção `users` no `user-data.yaml`:

```yaml
users:
  - name: novo-usuario
    groups: [sudo]
    # ... outras configurações
```

### Configurar Scripts Personalizados
Adicione comandos na seção `runcmd` no `user-data.yaml`:

```yaml
runcmd:
  - seu-comando-aqui
  - outro-comando
```

## 🔐 Segurança

### Senhas Padrão
- **Usuário admin**: `changeMe123!`
- **SEMPRE** altere as senhas após o primeiro login!

### SSH
- 🔑 Autenticação por chave pública configurada
- 🔒 Configurações de segurança aplicadas
- 🛡️ UFW firewall ativo

## 📊 Monitoramento

### Node Exporter
- 📈 Instalado automaticamente
- 🚪 Porta: 9100
- 📊 Métricas disponíveis para Prometheus

### Logs
- 📝 `/var/log/cloud-init-output.log` - Output do cloud-init
- 📝 `/var/log/homelab-first-boot.log` - Logs do primeiro boot
- 📝 `/var/log/vendor-data.log` - Logs do vendor data

## 🚀 Scripts Úteis

### System Info
```bash
sysinfo  # Mostra informações do sistema
```

### Aliases Docker
```bash
dps      # docker ps
dpsa     # docker ps -a
di       # docker images
dlog     # docker logs
```

## 🔄 Troubleshooting

### Verificar Status do Cloud-Init
```bash
cloud-init status
cloud-init analyze
```

### Ver Logs
```bash
tail -f /var/log/cloud-init-output.log
journalctl -u cloud-init
```

### Reprocessar Cloud-Init
```bash
cloud-init clean
cloud-init init
```

## 📋 Checklist Pós-Deploy

- [ ] SSH funcionando com chave pública
- [ ] Usuário admin criado com sudo
- [ ] Docker instalado e funcionando
- [ ] QEMU Guest Agent ativo
- [ ] Node Exporter rodando na porta 9100
- [ ] UFW firewall ativo
- [ ] Senhas padrão alteradas