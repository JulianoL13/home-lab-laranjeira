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
    vmid = var.vmid
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
      "[ -f \"$IMG\" ] || wget -O \"$IMG\" ${var.image_url}",
      "qm destroy ${var.vmid} --purge || true",
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
    type     = "ssh"
    host     = var.pm_host
    user     = var.pm_user
    password = var.pm_password
  }
}
