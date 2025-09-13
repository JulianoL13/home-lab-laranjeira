# Módulo Terraform: lxc-container

Cria um container LXC no Proxmox utilizando o recurso `proxmox_lxc` do provider `bpg/proxmox`.

## Exemplo de uso
```hcl
module "lxc_container" {
  source         = "./modules/lxc-container"
  hostname       = "ct01"
  vmid           = 200
  target_node    = "pve"
  ostemplate     = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  rootfs_storage = "local-lvm"
  rootfs_size    = "8G"
  cores          = 2
  memory         = 1024
  bridge         = "vmbr0"
  ip_address     = "192.168.1.60"
  cidr           = 24
  gateway        = "192.168.1.1"
  password       = var.ct_password
  mounts = [
    {
      slot    = 0
      storage = "local-lvm"
      mp      = "/data"
      size    = "10G"
    }
  ]
}
```

## Criando vários containers
É possível definir um conjunto de containers em um `local` e criar todos com `for_each`:

```hcl
locals {
  containers = {
    ct1 = { vmid = 200, ip = "192.168.1.61" }
    ct2 = { vmid = 201, ip = "192.168.1.62" }
  }
}

module "lxc_container" {
  for_each      = local.containers
  source        = "./modules/lxc-container"
  hostname      = each.key
  vmid          = each.value.vmid
  target_node   = "pve"
  ostemplate    = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  rootfs_storage = "local-lvm"
  rootfs_size    = "8G"
  cores         = 2
  memory        = 1024
  bridge        = "vmbr0"
  ip_address    = each.value.ip
  cidr          = 24
  gateway       = "192.168.1.1"
  password      = var.ct_password
}
```

## Saídas
- `container_id` – ID do container no Proxmox
- `container_ip` – Endereço IP configurado
