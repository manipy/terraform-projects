# Azure Deployment Prerequisites & Setup Guide

This guide contains all prerequisites and step-by-step instructions for setting up your Terraform deployment with GitHub Actions on Windows.

## Overview

Before pushing your code to GitHub and testing, you need to set up:
1. Azure networking resources (VNet and subnets)
2. Azure Storage Account for Terraform state
3. Azure Service Principal for GitHub Actions authentication
4. GitHub Secrets in your repository

## Azure Prerequisites Checklist

### ✅ Subscription (You likely have this)
- Active Azure subscription with Owner or Contributor permissions
- Verify: `az account show`

### ❌ Virtual Network (Must Create)
- Name: `my-vnet` (or your preferred name)
- Location: Same region as VM deployment
- Address space: `10.0.0.0/16`

### ❌ Subnets (Must Create)
- `web-subnet`: `10.0.1.0/24` (for Project 1)
- `app-subnet`: `10.0.2.0/24` (for Project 2)
- `db-subnet`: `10.0.3.0/24` (for Project 3)

### ❌ Storage Account (Must Create)
- Resource Group: `terraform-state-rg`
- Storage Account: `terraformstate12345` (must be globally unique)
- Container: `tfstate`

### ❌ Service Principal (Must Create)
- Name: `terraform-github-actions`
- Role: Contributor
- Used for GitHub Actions authentication

## GitHub Secrets Checklist

After Azure setup, add these secrets to your GitHub repository:

### Required Secrets:
1. `AZURE_CREDENTIALS` - Service principal JSON credentials
2. `AZURE_SUBSCRIPTION_ID` - Your Azure subscription ID
3. `BACKEND_RESOURCE_GROUP_NAME` - Resource group for storage account
4. `BACKEND_STORAGE_ACCOUNT_NAME` - Storage account name
5. `BACKEND_CONTAINER_NAME` - Container name for state files

## Step-by-Step Setup (Windows PowerShell)

### Step 1: Install Azure CLI (if not installed)
```powershell
# Download and install Azure CLI
# Visit: https://docs.microsoft.com/cli/azure/install-azure-cli-windows
```

### Step 2: Login to Azure
```powershell
az login
az account set --subscription <your-subscription-id>
```

### Step 3: Create Networking Resources
```powershell
# Create resource group for networking
az group create --name my-network-rg --location eastus

# Create Virtual Network
az network vnet create `
  --name my-vnet `
  --resource-group my-network-rg `
  --address-prefix 10.0.0.0/16

# Create subnets
az network vnet subnet create `
  --vnet-name my-vnet `
  --resource-group my-network-rg `
  --name web-subnet `
  --address-prefixes 10.0.1.0/24

az network vnet subnet create `
  --vnet-name my-vnet `
  --resource-group my-network-rg `
  --name app-subnet `
  --address-prefixes 10.0.2.0/24

az network vnet subnet create `
  --vnet-name my-vnet `
  --resource-group my-network-rg `
  --name db-subnet `
  --address-prefixes 10.0.3.0/24
```

### Step 4: Create Storage Account for Terraform State
```powershell
# Navigate to terraform-projects directory
cd F:\windsurf\terraform-projects

# Run the setup script
.\setup-storage-account.ps1
```

**Copy these values from the script output:**
- `BACKEND_RESOURCE_GROUP_NAME` (e.g., `terraform-state-rg`)
- `BACKEND_STORAGE_ACCOUNT_NAME` (e.g., `terraformstate12345`)
- `BACKEND_CONTAINER_NAME` (e.g., `tfstate`)

### Step 5: Create Service Principal for GitHub Actions
```powershell
# Navigate to terraform-projects directory
cd F:\windsurf\terraform-projects

# Run the service principal creation script
.\create-azure-sp.ps1
```

**Copy these values from the script output:**
- `AZURE_CREDENTIALS` (the entire JSON object)
- `AZURE_SUBSCRIPTION_ID`

### Step 6: Update backend.tf Files
Update each project's `backend.tf` file with your actual storage account details:

**Project 1:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"  # Your actual name
    container_name        = "tfstate"
    key                   = "project1.tfstate"
  }
}
```

**Project 2:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"  # Your actual name
    container_name        = "tfstate"
    key                   = "project2.tfstate"
  }
}
```

**Project 3:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"  # Your actual name
    container_name        = "tfstate"
    key                   = "project3.tfstate"
  }
}
```

### Step 7: Update terraform.tfvars Files
Update each project's `terraform.tfvars` with your actual values:

**Project 1 (F:\windsurf\terraform-projects\project1\terraform.tfvars):**
```hcl
resource_group_name     = "project1-web-rg"
resource_group_location = "eastus"

web_server_count = 2
vm_size          = "Standard_DS1_v2"
subnet_name      = "web-subnet"
vnet_name        = "my-vnet"

admin_username = "azureuser"
admin_password = "YourSecurePassword123!"

environment = "production"
```

**Project 2 (F:\windsurf\terraform-projects\project2\terraform.tfvars):**
```hcl
resource_group_name     = "project2-app-rg"
resource_group_location = "eastus"

app_server_count = 2
vm_size          = "Standard_DS2_v2"
subnet_name      = "app-subnet"
vnet_name        = "my-vnet"

admin_username   = "azureuser"
admin_password   = "YourSecurePassword123!"

environment      = "production"
windows_version  = "2019-Datacenter"
```

**Project 3 (F:\windsurf\terraform-projects\project3\terraform.tfvars):**
```hcl
resource_group_name     = "project3-mixed-rg"
resource_group_location = "eastus"

linux_web_count     = 2
windows_db_count    = 1
linux_vm_size       = "Standard_DS1_v2"
windows_vm_size     = "Standard_DS3_v2"
linux_subnet_name   = "web-subnet"
windows_subnet_name = "db-subnet"
vnet_name           = "my-vnet"

admin_username      = "azureuser"
admin_password      = "YourSecurePassword123!"

environment         = "production"
windows_version     = "2022-Datacenter"
```

### Step 8: Update Module Source URLs
Update the module source in each project's `main.tf` to point to your actual git repository:

**Example:**
```hcl
module "web_servers" {
  source = "git::https://github.com/YOUR-ORG/YOUR-REPO.git//terraform_modules/avm?ref=main"
  # ... rest of configuration
}
```

### Step 9: Add GitHub Secrets
Go to your GitHub repository:
1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret with the exact name and value:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `AZURE_CREDENTIALS` | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` | Service principal script output |
| `AZURE_SUBSCRIPTION_ID` | `12345678-1234-1234-1234-123456789012` | Service principal script output |
| `BACKEND_RESOURCE_GROUP_NAME` | `terraform-state-rg` | Storage account script output |
| `BACKEND_STORAGE_ACCOUNT_NAME` | `terraformstate12345` | Storage account script output |
| `BACKEND_CONTAINER_NAME` | `tfstate` | Storage account script output |

## Verification Checklist

Before pushing to GitHub, verify:

### Azure Resources:
- [ ] Azure subscription is active
- [ ] VNet `my-vnet` exists in `my-network-rg`
- [ ] Subnets `web-subnet`, `app-subnet`, `db-subnet` exist
- [ ] Storage account exists in `terraform-state-rg`
- [ ] Container `tfstate` exists in storage account
- [ ] Service principal `terraform-github-actions` exists

### GitHub Secrets:
- [ ] `AZURE_CREDENTIALS` added (JSON format)
- [ ] `AZURE_SUBSCRIPTION_ID` added
- [ ] `BACKEND_RESOURCE_GROUP_NAME` added
- [ ] `BACKEND_STORAGE_ACCOUNT_NAME` added
- [ ] `BACKEND_CONTAINER_NAME` added

### Local Files:
- [ ] `backend.tf` files updated with actual storage account details
- [ ] `terraform.tfvars` files updated with your values
- [ ] Module source URLs updated to point to your git repository

## Verification Commands

```powershell
# Verify Azure resources
az network vnet show --name my-vnet --resource-group my-network-rg
az network vnet subnet list --vnet-name my-vnet --resource-group my-network-rg --output table
az storage account show --name terraformstate12345 --resource-group terra-state-rg
az ad sp show --id "your-client-id"

# Verify local Terraform works
cd F:\windsurf\terraform-projects\project1
terraform init
terraform plan
```

## GitHub Actions Authentication Explained

### What GitHub Actions Uses:
GitHub Actions uses the **Service Principal credentials** (client ID + client secret + subscription ID + tenant ID) from the `AZURE_CREDENTIALS` secret.

### How It Works:
1. **Not Subscription Alone**: Just having a subscription ID isn't enough
2. **Service Principal**: The workflow authenticates using the service principal credentials
3. **Three Components Required**:
   - **Client ID**: Identifies the service principal
   - **Client Secret**: Proves identity (like a password)
   - **Subscription ID**: Tells Azure which subscription to use
   - **Tenant ID**: Identifies your Azure AD tenant

### Authentication Flow:
```
GitHub Actions → Reads AZURE_CREDENTIALS secret → Authenticates with Azure → Gets access token → Deploys resources
```

### Why Service Principal Instead of Subscription:
- **Security**: Can't use subscription ID alone (no authentication)
- **Permissions**: Service principal has specific scoped permissions
- **Auditability**: All actions are logged under the service principal
- **Revocability**: Can immediately revoke access if compromised

## Cost Estimates

### Azure Resources:
- **Storage Account**: ~$0.02 per GB/month (state files are small)
- **VMs**: Depends on your chosen sizes and count
- **Networking**: VNet and subnets are free

### GitHub Actions:
- **Public Repository**: 2,000 free minutes/month
- **Private Repository**: 2,000 free minutes/month, then $0.008/minute

### Total Monthly Cost:
- **State Storage**: <$1
- **GitHub Actions**: Free for typical usage
- **VMs**: Depends on your configuration

## Troubleshooting

### Azure CLI Issues:
```powershell
# Update Azure CLI
az upgrade

# Re-login
az logout
az login
```

### Service Principal Issues:
```powershell
# List service principals
az ad sp list --display-name "terraform-github-actions"

# Delete and recreate if needed
az ad sp delete --id "your-client-id"
```

### Storage Account Issues:
```powershell
# Check storage account
az storage account show --name terraformstate12345 --resource-group terra-state-rg

# List containers
az storage container list --account-name terraformstate12345 --auth-mode login
```

## Security Best Practices

1. **Use Strong Passwords**: Use complex passwords for VM admin accounts
2. **Rotate Secrets**: Regularly rotate service principal credentials
3. **Limit Permissions**: Give service principal only necessary permissions
4. **Monitor Logs**: Regularly check Azure sign-in logs
5. **Enable MFA**: Enable multi-factor authentication on your Azure account

## Next Steps

Once all prerequisites are complete:

1. **Push to GitHub**: Push your code to your GitHub repository
2. **Test Workflow**: Go to Actions tab and run the workflow
3. **Start with Plan**: Use `plan` action first to verify configuration
4. **Review Plan**: Review the Terraform plan output
5. **Apply**: Use `apply` action to deploy resources
6. **Monitor**: Monitor the deployment in GitHub Actions logs

## Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Service Principals](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)
