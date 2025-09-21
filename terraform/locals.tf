locals {
  vm_configs = {
    "k3s-master-00" = {
      vmid       = 1001
      node_name  = var.default_node_name
      cores      = 2
      memory     = 4096
      disk_size  = 30
      ip_address = "192.168.0.170/24"
      gateway    = "192.168.0.1"
      template   = var.vm_template_name
      ciuser     = "debian"
      tags       = ["k3s", "master", "terraform"]
    }
    "k3s-worker-01" = {
      vmid       = 1002
      node_name  = var.default_node_name
      cores      = 2
      memory     = 4096
      disk_size  = 30
      ip_address = "192.168.0.171/24"
      gateway    = "192.168.0.1"
      template   = var.vm_template_name
      ciuser     = "debian"
      tags       = ["k3s", "worker", "terraform"]
    }
    "k3s-worker-02" = {
      vmid       = 1003
      node_name  = var.default_node_name
      cores      = 2
      memory     = 4096
      disk_size  = 30
      ip_address = "192.168.0.172/24"
      gateway    = "192.168.0.1" # ✅ Corrigido - era 192.168.50.1
      template   = var.vm_template_name
      ciuser     = "debian"
      tags       = ["k3s", "worker", "terraform"]
    }
  }

  container_configs = {
    "monitoring-01" = {
      vmid       = 2001
      node_name  = var.default_node_name
      cores      = 2
      memory     = 2048
      disk_size  = 20
      ip_address = "192.168.0.231/24"
      gateway    = "192.168.0.1"
      template   = var.container_template_name
      hostname   = "monitoring-01"
      tags       = ["monitoring", "prometheus", "terraform"]
    }
    "database-01" = {
      vmid       = 2002
      node_name  = var.default_node_name
      cores      = 2
      memory     = 4096
      disk_size  = 50
      ip_address = "192.168.0.232/24"
      gateway    = "192.168.0.1"
      template   = var.container_template_name
      hostname   = "database-01"
      tags       = ["database", "postgresql", "terraform"]
    }
  }
}
