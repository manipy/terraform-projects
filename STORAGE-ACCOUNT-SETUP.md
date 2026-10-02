# Terraform State Storage Account Setup Guide

This guide explains how to manually set up an Azure Storage Account for Terraform state management.

## Why Use Remote State?

Storing Terraform state in Azure Storage Account provides:
- **Collaboration**: Multiple team members can work on the same infrastructure
- **Security**: State files are encrypted at rest
- **Locking**: Prevents concurrent state modifications
- **Versioning**: Optional state file versioning for rollback capability
- **Reliability**: State is stored in a durable, managed service

## Manual Setup Steps

### 1. Create Resource Group

```bash
az group create \
  --name terraform-state-rg \
  --location eastus
```

### 2. Create Storage Account

```bash
az storage account create \
  --resource-group terraform-state-rg \
  --name terraformstate12345 \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true
```

**Note**: Storage account name must be globally unique and lowercase.

### 3. Get Storage Account Key

```bash
az storage account keys list \
  --resource-group terraform-state-rg \
  --account-name terraformstate12345 \
  --query '[0].value' -o tsv
```

### 4. Create Container

```bash
az storage container create \
  --name tfstate \
  --account-name terraformstate12345 \
  --account-key <your-storage-account-key>
```

### 5. Update backend.tf Files

Update the `backend.tf` file in each project directory with your values:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"
    container_name        = "tfstate"
    key                   = "project1/terraform.tfstate"
  }
}
```

Each project should have a unique `key` value:
- Project 1: `project1/terraform.tfstate`
- Project 2: `project2/terraform.tfstate`
- Project 3: `project3/terraform.tfstate`

## Authentication Methods

### Method 1: Azure CLI (Recommended)

Terraform will automatically use your Azure CLI credentials:

```bash
az login
terraform init
```

### Method 2: Environment Variables

Set the storage account key as an environment variable:

```bash
export ARM_ACCESS_KEY="your-storage-account-key"
terraform init
```

### Method 3: Managed Identity (Advanced)

Configure the storage account to use managed identity for authentication.

## Backend Configuration Options

### Basic Configuration

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"
    container_name        = "tfstate"
    key                   = "project1/terraform.tfstate"
  }
}
```

### Advanced Configuration with State Locking

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"
    container_name        = "tfstate"
    key                   = "project1/terraform.tfstate"

    # Optional: State locking and encryption
    use_azuread_auth      = true
    subscription_id       = "your-subscription-id"
    tenant_id             = "your-tenant-id"
  }
}
```

### Configuration with SAS Token

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"
    container_name        = "tfstate"
    key                   = "project1/terraform.tfstate"
    sas_token             = "your-sas-token"
  }
}
```

## State Management Best Practices

### 1. Use Separate State Files

Each project should have its own state file:
- `project1/terraform.tfstate`
- `project2/terraform.tfstate`
- `project3/terraform.tfstate`

### 2. Enable Versioning (Optional)

Enable storage account versioning for state history:

```bash
az storage account blob-service-property update \
  --account-name terraformstate12345 \
  --enable-versioning true
```

### 3. Regular State Backups

Export state regularly for backup:

```bash
terraform state pull > terraform-state-backup-$(date +%Y%m%d).tfstate
```

### 4. State File Encryption

State files are automatically encrypted when stored in Azure Storage Account.

### 5. Access Control

Restrict access to the storage account using:
- Azure RBAC roles
- Network access rules
- Private endpoints

## Troubleshooting

### Authentication Issues

**Error**: `Error: Error building AzureRM Backend: Error validating AzureRM Backend credentials`

**Solution**: Ensure you're authenticated with Azure CLI:
```bash
az login
az account set --subscription <your-subscription-id>
```

### Storage Account Not Found

**Error**: `Error: storage account name not found`

**Solution**: Verify the storage account name and that you have access to it.

### Container Not Found

**Error**: `Error: container not found`

**Solution**: Create the container manually or verify the container name in backend.tf.

### State Lock Issues

**Error**: `Error: Error acquiring the state lock`

**Solution**: Force unlock if necessary (use with caution):
```bash
terraform force-unlock <LOCK_ID>
```

## Cost Considerations

Storage Account costs for Terraform state:
- **Storage**: Minimal (state files are typically small)
- **Operations**: Negligible (read/write operations are infrequent)
- **Data Transfer**: Minimal (usually within same region)

Estimated monthly cost: <$1 for typical usage.

## Security Recommendations

1. **Use Managed Identity**: Prefer managed identity over access keys
2. **Network Restrictions**: Restrict storage account access to specific IPs
3. **Private Endpoints**: Use private endpoints for enhanced security
4. **Key Rotation**: Regularly rotate storage account keys
5. **Access Logging**: Enable storage account logging for audit trails

## Migration from Local to Remote State

If you have existing local state, migrate it:

```bash
# Initialize with new backend
terraform init \
  -backend-config="resource_group_name=terraform-state-rg" \
  -backend-config="storage_account_name=terraformstate12345" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=project1/terraform.tfstate"

# Terraform will prompt to copy existing state
```

## Additional Resources

- [Terraform Azure Backend Documentation](https://www.terraform.io/language/settings/backends/azurerm)
- [Azure Storage Account Documentation](https://docs.microsoft.com/azure/storage/common/storage-account-overview)
- [Terraform State Best Practices](https://www.terraform.io/cloud-docs/best-practices)
