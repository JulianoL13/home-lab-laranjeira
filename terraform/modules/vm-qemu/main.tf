locals {
  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    user    = var.user
    ssh_key = var.ssh_key
  })

  meta_data = templatefile("${path.module}/templates/meta-data.tpl", {
    hostname = var.name
  })

  network_config = templatefile("${path.module}/templates/network-config.tpl", {
    net_name   = var.net_name
    ip_address = var.ip_address
    cidr       = var.cidr
    gateway    = var.gateway
  })
}

resource "null_resource" "vm" {
  triggers = {
    config = sha1(jsonencode({
      vmid         = var.vmid
      name         = var.name
      cores        = var.cores
      memory       = var.memory
      disk_size    = var.disk_size
      storage      = var.storage
      bridge       = var.bridge
      ip_address   = var.ip_address
      cidr         = var.cidr
      gateway      = var.gateway
      ssh_key      = var.ssh_key
      user         = var.user
      image_url    = var.image_url
      image_name   = var.image_name
      image_sha256 = var.image_sha256
      net_name     = var.net_name
      pm_host      = var.pm_host
      pm_user      = var.pm_user
      pm_password  = var.pm_password
    }))
  }

  provisioner "file" {
    content     = local.user_data
    destination = "/tmp/${var.name}-user-data"
  }

  provisioner "file" {
    content     = local.meta_data
    destination = "/tmp/${var.name}-meta-data"
  }

  provisioner "file" {
    content     = local.network_config
    destination = "/tmp/${var.name}-network-config"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "ISO_DIR=/var/lib/vz/template/iso",
      "IMG=$ISO_DIR/${var.image_name}",
        "[ -f \"$IMG\" ] || (wget --secure-protocol=TLSv1_2 -O \"$IMG\" ${var.image_url} && echo \"${var.image_sha256}  $IMG\" | sha256sum -c -)",
        "(qm status ${var.vmid} >/dev/null 2>&1 && qm destroy ${var.vmid} --purge) || echo 'VM ${var.vmid} does not exist, skipping destroy'",
      "qm create ${var.vmid} --name ${var.name} --memory ${var.memory} --cores ${var.cores} --net0 virtio,bridge=${var.bridge} --scsihw virtio-scsi-pci",
      "qm importdisk ${var.vmid} $IMG ${var.storage}",
      "qm set ${var.vmid} --scsi0 ${var.storage}:vm-${var.vmid}-disk-0",
      "qm resize ${var.vmid} scsi0 ${var.disk_size}",
      "cloud-localds $ISO_DIR/${var.name}-seed.iso /tmp/${var.name}-user-data /tmp/${var.name}-meta-data --network-config=/tmp/${var.name}-network-config",
      "qm set ${var.vmid} --boot c --bootdisk scsi0 --ide2 local:iso/${var.name}-seed.iso,media=cdrom --serial0 socket --vga serial0",
      "qm start ${var.vmid}"
    ]
  }

  connection {
    type        = "ssh"
    host        = var.pm_host
    user        = var.pm_user
    private_key = var.ssh_private_key
  }
}
