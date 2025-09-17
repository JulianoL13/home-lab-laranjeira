# Simplified Homelab Terraform Configuration

This is a simplified and improved version of the homelab Terraform configuration that follows best practices and eliminates over-engineering.

## Key Improvements

### ✅ **Simplifications Made**
- **Removed complex merge logic** from modules
- **Eliminated duplicated code** between VM and container modules
- **Individual machine definitions** in main.tf locals (clear and explicit)
- **Simple, direct module interfaces** without unnecessary abstractions
- **Unified approach** with consistent patterns

### ✅ **Security Improvements**
- **Environment variables** for sensitive data (no hardcoded passwords)
- **API token support** (recommended over passwords)
- **Sensitive variable markings** for Terraform state protection
- **Clear security documentation** and best practices

### ✅ **Best Practices Implemented**
- **Useful outputs** for IP addresses and resource IDs
- **Clear module separation** with single responsibility
- **Consistent naming conventions**
- **Proper documentation** and examples
- **Validation and error handling**

## Architecture

### Modules
- **`simple-vm`**: Creates VMs from templates or cloud images
- **`simple-container`**: Creates LXC containers

### Resources Created
- **1 Template VM** (1000) - Ubuntu 22.04 cloud image
- **3 VMs** (1001-1003) - Web, DB, Cache servers
- **3 Containers** (2001-2003) - Web, DB, Cache containers

## Usage

### 1. Setup Environment Variables (Recommended)
```bash
# For API token authentication (RECOMMENDED)
export TF_VAR_pm_api_token_id="root@pam!terraform"
export TF_VAR_pm_api_token_secret="your-secret-token"

# For password authentication (less secure)
export TF_VAR_pm_password="your_password"

# Container password
export TF_VAR_lxc_password="secure_container_password"
```

### 2. Configure terraform.tfvars
```bash
cp terraform.tfvars.example.new terraform.tfvars
# Edit terraform.tfvars with your specific settings
```

### 3. Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Configuration

All machine definitions are in `main_simplified.tf` locals:

```hcl
locals {
  vms = {
    web = {
      vmid       = 1001
      name       = "homelab-web"
      ip_address = "192.168.0.101"
      memory     = 4096
      cores      = 2
      disk_size  = "50G"
    }
    # ... more VMs
  }
  
  containers = {
    web = {
      vmid        = 2001
      name        = "homelab-web-ct"
      ip_address  = "192.168.0.201"
      memory      = 2048
      cores       = 2
      rootfs_size = 10
    }
    # ... more containers
  }
}
```

## Outputs

After deployment, you'll get useful information:

```bash
terraform output vm_ips
terraform output container_ips
terraform output homelab_summary
```

## Migration from Complex Version

If migrating from the complex version:

1. **Backup your terraform.tfstate**
2. **Update module calls** to use new simplified modules
3. **Set environment variables** for sensitive data
4. **Test with `terraform plan`** before applying

## Comparison: Before vs After

### Before (Over-engineered)
- Complex merge() logic in modules
- Duplicated processing between VM/container modules
- Many unnecessary variables and abstractions
- Hardcoded sensitive values
- Difficult to understand and maintain

### After (Simplified)
- Clear, individual machine definitions
- Simple, focused modules
- Environment variables for security
- Easy to understand and modify
- Follows Terraform best practices

## Adding New Machines

To add a new VM:
1. Add entry to `locals.vms`
2. Create new `module "vm_newname"` block
3. Update outputs if needed

To add a new container:
1. Add entry to `locals.containers`  
2. Create new `module "container_newname"` block
3. Update outputs if needed

## Security Notes

- ⚠️ **Never commit terraform.tfvars with real credentials**
- ✅ **Use API tokens instead of passwords when possible**
- ✅ **Use environment variables for sensitive data**
- ✅ **Keep terraform.tfvars in .gitignore**
- ✅ **Use strong, unique passwords**