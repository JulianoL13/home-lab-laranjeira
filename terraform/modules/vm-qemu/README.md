# Módulo Terraform: vm-qemu

Cria um *template* de VM no Proxmox a partir de uma imagem cloud. O download da imagem é feito via recurso `proxmox_virtual_environment_download_file` e a configuração inicial é aplicada através de Cloud-Init usando snippets.

## Exemplo de uso
```hcl
module "vm_qemu" {
  source      = "./modules/vm-qemu"
  node_name   = "pve"
  name        = "debian-template"
  vmid        = 101
  cores       = 2
  memory      = 2048
  disk_size   = 20
  storage     = "local-lvm"
  bridge      = "vmbr0"
  ip_address  = "192.168.1.50"
  cidr        = 24
  gateway     = "192.168.1.1"
  ssh_key     = file("~/.ssh/id_rsa.pub")
  user        = "debian"
  image_url   = "https://cloud-images.debian.org/debian-12-genericcloud-amd64.qcow2"
  image_name  = "debian-12-genericcloud-amd64.qcow2"
  image_sha256 = "<sha256>"
}
```

## Saídas
- `vm_id` – ID da VM criada
- `vm_ip` – Endereço IP configurado via Cloud-Init
