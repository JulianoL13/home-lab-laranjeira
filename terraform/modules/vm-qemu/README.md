# Módulo Terraform: vm-qemu

Cria uma VM no Proxmox a partir de uma imagem cloud baixada no momento do `apply`, gerando automaticamente um ISO de Cloud-Init para configuração inicial.

Requer que o host Proxmox tenha o utilitário `cloud-localds` instalado.

## Exemplo de uso
```hcl
module "vm_qemu" {
  source       = "./modules/vm-qemu"
  pm_host      = "192.168.1.10"
  pm_user      = "root"
  pm_password  = var.pm_password
  name         = "servidor01"
  vmid         = 101
  cores        = 2
  memory       = 2048
  disk_size    = "20G"
  storage      = "local-lvm"
  bridge       = "vmbr0"
  ip_address   = "192.168.1.50"
  cidr         = 24
  gateway      = "192.168.1.1"
  ssh_key      = file("~/.ssh/id_rsa.pub")
  user         = "debian"
  image_url    = "https://cloud-images.debian.org/debian-12-genericcloud-amd64.qcow2"
  image_name   = "debian-12-genericcloud-amd64.qcow2"
}
```

## Criando várias VMs
É possível definir um conjunto de VMs em um `local` e criar todas com `for_each`:

```hcl
locals {
  vms = {
    srv1 = {
      name       = "srv1"
      vmid       = 101
      ip_address = "192.168.1.51"
    }
    srv2 = {
      name       = "srv2"
      vmid       = 102
      ip_address = "192.168.1.52"
    }
  }
}

module "vm_qemu" {
  for_each    = local.vms
  source      = "./modules/vm-qemu"
  pm_host     = "192.168.1.10"
  pm_user     = "root"
  pm_password = var.pm_password
  name        = each.value.name
  vmid        = each.value.vmid
  cores       = 2
  memory      = 2048
  disk_size   = "20G"
  storage     = "local-lvm"
  bridge      = "vmbr0"
  ip_address  = each.value.ip_address
  cidr        = 24
  gateway     = "192.168.1.1"
  ssh_key     = file("~/.ssh/id_rsa.pub")
  user        = "debian"
  image_url   = "https://cloud-images.debian.org/debian-12-genericcloud-amd64.qcow2"
  image_name  = "debian-12-genericcloud-amd64.qcow2"
}
```

## Saídas
- `vm_id` – ID da VM no Proxmox
- `vm_ip` – Endereço IP configurado via Cloud-Init
