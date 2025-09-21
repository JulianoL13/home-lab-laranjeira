# Exemplos de Configurações Avançadas

Este arquivo contém exemplos de configurações avançadas que você pode usar no seu `terraform.tfvars`.

## 🚀 Performance Máxima

```hcl
# CPU de alta performance
vm_cpu_type         = "host"  # Pass-through da CPU do host
vm_cpu_architecture = "x86_64"

# Disco com performance otimizada
vm_disk_cache       = "none"     # Para storage rápido (SSD/NVMe)
vm_disk_iothread    = true       # Habilitar iothread
vm_disk_file_format = "raw"      # Para máxima performance

# Rede otimizada
vm_network_model    = "virtio"   # Rede paravirtualizada
```

## 🛡️ Segurança Máxima

```hcl
# UEFI com Secure Boot
vm_bios_type = "ovmf"

# Containers privilegiados desabilitados
container_unprivileged = true

# Features de segurança para containers
container_features_nesting = false  # Desabilitar nesting se não precisar
container_features_fuse    = false  # Desabilitar FUSE se não precisar

# Proteção de recursos
vm_protection        = true
container_protection = true
```

## 🌐 Rede Avançada

```hcl
# DNS personalizados
cloudinit_dns_servers = ["1.1.1.1", "1.0.0.1"]  # Cloudflare
# cloudinit_dns_servers = ["208.67.222.222", "208.67.220.220"]  # OpenDNS

# Domínio customizado
cloudinit_dns_domain = "meulab.com.br"
```

## 🐳 Configuração para Docker Swarm

```hcl
# No locals.tf para managers
vm_configs = {
  "swarm-manager-01" = {
    vmid        = 110
    cores       = 2
    memory      = 4096
    disk_size   = 50
    ip_address  = "192.168.1.10/24"
    gateway     = "192.168.1.1"
    ciuser      = "admin"
    tags        = ["docker", "swarm", "manager", "terraform"]
  }
  "swarm-manager-02" = {
    vmid        = 111
    cores       = 2
    memory      = 4096
    disk_size   = 50
    ip_address  = "192.168.1.11/24"
    gateway     = "192.168.1.1"
    ciuser      = "admin"
    tags        = ["docker", "swarm", "manager", "terraform"]
  }
  "swarm-worker-01" = {
    vmid        = 120
    cores       = 4
    memory      = 8192
    disk_size   = 100
    ip_address  = "192.168.1.20/24"
    gateway     = "192.168.1.1"
    ciuser      = "admin"
    tags        = ["docker", "swarm", "worker", "terraform"]
  }
}
```

## 🎯 Configuração para Kubernetes

```hcl
# No locals.tf para cluster K8s
vm_configs = {
  "k8s-master-01" = {
    vmid        = 101
    cores       = 4
    memory      = 8192
    disk_size   = 50
    ip_address  = "10.0.1.10/24"
    gateway     = "10.0.1.1"
    ciuser      = "admin"
    tags        = ["kubernetes", "master", "control-plane", "terraform"]
  }
  "k8s-worker-01" = {
    vmid        = 111
    cores       = 6
    memory      = 16384
    disk_size   = 100
    ip_address  = "10.0.1.11/24"
    gateway     = "10.0.1.1"
    ciuser      = "admin"
    tags        = ["kubernetes", "worker", "node", "terraform"]
  }
  "k8s-worker-02" = {
    vmid        = 112
    cores       = 6
    memory      = 16384
    disk_size   = 100
    ip_address  = "10.0.1.12/24"
    gateway     = "10.0.1.1"
    ciuser      = "admin"
    tags        = ["kubernetes", "worker", "node", "terraform"]
  }
}
```

## 📊 Configuração para Monitoramento

```hcl
# Containers para stack de monitoramento
container_configs = {
  "prometheus" = {
    vmid        = 201
    cores       = 2
    memory      = 4096
    disk_size   = 50
    ip_address  = "192.168.1.201/24"
    gateway     = "192.168.1.1"
    hostname    = "prometheus"
    tags        = ["monitoring", "prometheus", "terraform"]
  }
  "grafana" = {
    vmid        = 202
    cores       = 2
    memory      = 2048
    disk_size   = 20
    ip_address  = "192.168.1.202/24"
    gateway     = "192.168.1.1"
    hostname    = "grafana"
    tags        = ["monitoring", "grafana", "terraform"]
  }
  "alertmanager" = {
    vmid        = 203
    cores       = 1
    memory      = 1024
    disk_size   = 10
    ip_address  = "192.168.1.203/24"
    gateway     = "192.168.1.1"
    hostname    = "alertmanager"
    tags        = ["monitoring", "alertmanager", "terraform"]
  }
}
```

## 🗄️ Configuração para Banco de Dados

```hcl
# VMs para bancos de dados
vm_configs = {
  "postgres-primary" = {
    vmid        = 301
    cores       = 4
    memory      = 8192
    disk_size   = 200
    ip_address  = "192.168.2.10/24"
    gateway     = "192.168.2.1"
    vlan_id     = 200  # VLAN isolada para DB
    ciuser      = "admin"
    tags        = ["database", "postgresql", "primary", "terraform"]
  }
  "postgres-replica" = {
    vmid        = 302
    cores       = 4
    memory      = 8192
    disk_size   = 200
    ip_address  = "192.168.2.11/24"
    gateway     = "192.168.2.1"
    vlan_id     = 200
    ciuser      = "admin"
    tags        = ["database", "postgresql", "replica", "terraform"]
  }
}
```

## 🌐 Configuração Multi-VLAN

```hcl
# DMZ - Serviços públicos
vm_configs = {
  "web-server-01" = {
    vmid        = 401
    cores       = 2
    memory      = 4096
    disk_size   = 30
    ip_address  = "192.168.10.10/24"
    gateway     = "192.168.10.1"
    vlan_id     = 10  # VLAN DMZ
    ciuser      = "admin"
    tags        = ["web", "dmz", "public", "terraform"]
  }
}

# Rede interna - Serviços privados
container_configs = {
  "internal-app" = {
    vmid        = 501
    cores       = 2
    memory      = 2048
    disk_size   = 20
    ip_address  = "10.10.10.10/24"
    gateway     = "10.10.10.1"
    vlan_id     = 100  # VLAN interna
    hostname    = "internal-app"
    tags        = ["app", "internal", "private", "terraform"]
  }
}
```

## 🔧 Configuração para Desenvolvimento

```hcl
# Ambiente de desenvolvimento
vm_configs = {
  "dev-workstation" = {
    vmid        = 600
    cores       = 8
    memory      = 16384
    disk_size   = 200
    ip_address  = "192.168.3.10/24"
    gateway     = "192.168.3.1"
    ciuser      = "admin"
    tags        = ["development", "workstation", "terraform"]
  }
}

# Container para testes
container_configs = {
  "test-env" = {
    vmid        = 610
    cores       = 2
    memory      = 4096
    disk_size   = 50
    ip_address  = "192.168.3.20/24"
    gateway     = "192.168.3.1"
    hostname    = "test-env"
    tags        = ["development", "testing", "terraform"]
  }
}
```

## 🎛️ Configurações Especiais

### Usando Imagens Customizadas

```hcl
# Imagem Ubuntu ao invés de Debian
vm_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
vm_image_filename = "jammy-server-cloudimg-amd64.qcow2"

# Template LXC do Ubuntu
container_image_url = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
container_image_filename = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
```

### Storage Alternativo

```hcl
# Usar storage ZFS
storage_name = "local-zfs"

# Usar storage compartilhado
storage_name = "ceph-storage"
```

### Bridge Alternativa

```hcl
# Usar bridge OVS
bridge_name = "vmbr1"
```

## 📝 Notas Importantes

1. **VLANs**: Certifique-se de que as VLANs estão configuradas no Proxmox
2. **Storage**: Verifique se o storage especificado existe e tem espaço
3. **IPs**: Use ranges de IP que não conflitem com sua rede existente
4. **Tags**: Use tags consistentes para facilitar a organização
5. **Recursos**: Dimensione CPU/Memory baseado na capacidade do seu hardware