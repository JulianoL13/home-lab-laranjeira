provider "proxmox" {
  endpoint = var.pm_api_url

  api_token = var.pm_api_token_id != null && var.pm_api_token_secret != null ? "${var.pm_api_token_id}=${var.pm_api_token_secret}" : null

  username = var.pm_api_token_id == null ? var.pm_user : null
  password = var.pm_api_token_id == null ? var.pm_password : null

  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}
