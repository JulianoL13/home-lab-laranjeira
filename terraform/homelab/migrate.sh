#!/bin/bash

# Terraform Homelab Migration Script
# Migrates from complex to simplified configuration

echo "🚀 Terraform Homelab Simplification Migration"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "main.tf" ] || [ ! -f "variables.tf" ]; then
    print_error "Please run this script from the terraform/homelab directory"
    exit 1
fi

echo ""
echo "This script will:"
echo "1. Backup your current configuration"
echo "2. Check for required environment variables"
echo "3. Validate the new simplified configuration"
echo "4. Provide next steps"
echo ""

read -p "Continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

# 1. Backup current state
echo ""
echo "1. Creating backup..."
if [ ! -d "backup" ]; then
    mkdir backup
fi

# Backup terraform state if it exists
if [ -f "../state/terraform.tfstate" ]; then
    cp ../state/terraform.tfstate backup/terraform.tfstate.backup
    print_status "Terraform state backed up"
else
    print_warning "No terraform state found to backup"
fi

print_status "Backup completed in ./backup/"

# 2. Check environment variables
echo ""
echo "2. Checking security configuration..."

# Check for sensitive variables in environment
if [ -z "$TF_VAR_pm_password" ] && [ -z "$TF_VAR_pm_api_token_secret" ]; then
    print_warning "No sensitive environment variables detected"
    echo "   For security, set one of:"
    echo "   export TF_VAR_pm_password='your_password'"
    echo "   export TF_VAR_pm_api_token_id='root@pam!terraform'"
    echo "   export TF_VAR_pm_api_token_secret='your_token_secret'"
fi

if [ -z "$TF_VAR_lxc_password" ]; then
    print_warning "LXC password not set in environment"
    echo "   Recommended: export TF_VAR_lxc_password='secure_password'"
fi

# 3. Validate configuration
echo ""
echo "3. Validating new configuration..."

if terraform validate > /dev/null 2>&1; then
    print_status "Configuration is valid"
else
    print_error "Configuration validation failed"
    echo "Run 'terraform validate' for details"
    exit 1
fi

# 4. Check for terraform.tfvars
echo ""
echo "4. Checking configuration files..."

if [ ! -f "terraform.tfvars" ]; then
    print_warning "No terraform.tfvars found"
    echo "   Copy terraform.tfvars.example to terraform.tfvars and configure"
else
    # Check if terraform.tfvars contains sensitive data
    if grep -q "password.*=" terraform.tfvars 2>/dev/null; then
        print_warning "terraform.tfvars contains hardcoded passwords"
        echo "   Consider using environment variables instead"
    fi
fi

# 5. Summary
echo ""
echo "🎉 Migration validation completed!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Configure terraform.tfvars (copy from terraform.tfvars.example)"
echo "2. Set environment variables for sensitive data:"
echo "   export TF_VAR_pm_api_token_id='root@pam!terraform'"
echo "   export TF_VAR_pm_api_token_secret='your_token'"
echo "   export TF_VAR_lxc_password='secure_password'"
echo "3. Run: terraform plan"
echo "4. Run: terraform apply"
echo ""
echo "📚 Key Changes:"
echo "==============="
echo "✅ Simplified modules (no complex merge logic)"
echo "✅ Individual machine definitions in locals"
echo "✅ Environment variables for security"
echo "✅ Useful outputs for IPs and IDs"
echo "✅ Better documentation and examples"
echo ""
echo "🔗 Documentation: See README_simplified.md for full details"
echo ""
print_status "Migration preparation complete!"