# GitHub Actions Setup Guide

This guide explains how to set up GitHub Actions for deploying your Terraform projects.

## Prerequisites

1. Azure Service Principal with appropriate permissions
2. GitHub Repository with your Terraform code
3. Azure Storage Account for Terraform state (created via setup scripts)

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### Required Secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | Azure service principal credentials (JSON) | `{"clientId":"...","clientSecret":"...","subscriptionId":"..."}` |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `12345678-1234-1234-1234-123456789012` |
| `BACKEND_RESOURCE_GROUP_NAME` | Resource group for storage account | `terraform-state-rg` |
| `BACKEND_STORAGE_ACCOUNT_NAME` | Storage account name | `terraformstate12345` |
| `BACKEND_CONTAINER_NAME` | Container name for state files | `tfstate` |

## Creating Azure Service Principal

### Option 1: Using Azure CLI

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "terraform-github-actions" \
  --role "Contributor" \
  --scopes /subscriptions/<your-subscription-id> \
  --json-auth > sp.json

# Get the credentials
cat sp.json
```

Copy the JSON output and add it as the `AZURE_CREDENTIALS` secret in GitHub.

### Option 2: Using Azure Portal

1. Go to Azure Portal → Azure Active Directory → App registrations
2. Click "New registration"
3. Name: `terraform-github-actions`
4. Redirect URI: Web → `https://github.com/your-org/your-repo`
5. Register the application

6. Go to "Certificates & secrets" → "New client secret"
7. Name: `github-actions-secret`
8. Copy the secret value

9. Go to "Subscriptions" → Access control (IAM)
10. Add role assignment → Contributor
11. Assign access to: `terraform-github-actions` application

10. Create JSON credentials:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

Add this JSON as `AZURE_CREDENTIALS` secret.

## Storage Account Setup

### Using Provided Scripts

**PowerShell:**
```powershell
cd F:\windsurf\terraform-projects
.\setup-storage-account.ps1
```

**Bash:**
```bash
cd F:\windsurf\terraform-projects
chmod +x setup-storage-account.sh
./setup-storage-account.sh
```

### Manual Setup

```bash
# Create resource group
az group create --name terraform-state-rg --location eastus

# Create storage account
az storage account create \
  --name terraformstate$(date +%s | head -c 6) \
  --resource-group terraform-state-rg \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group terraform-state-rg \
  --account-name terraformstate12345 \
  --query '[0].value' -o tsv)

# Create container
az storage container create \
  --name tfstate \
  --account-name terraformstate12345 \
  --account-key $STORAGE_KEY
```

### Update backend.tf Files

After creating the storage account, update the `backend.tf` files in each project:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"  # Your actual storage account name
    container_name        = "tfstate"
    key                   = "project1.tfstate"    # Unique for each project
  }
}
```

## Workflow Usage

### Triggering the Workflow

1. Go to your GitHub repository
2. Click "Actions" tab
3. Select "Deploy Terraform Projects" workflow
4. Click "Run workflow"
5. Select branch (usually `main`)
6. Choose parameters:
   - **Project**: `project1`, `project2`, `project3`, or `all`
   - **Action**: `plan`, `apply`, or `destroy`
   - **Auto-approve**: Check for automatic apply (be careful!)

### Workflow Parameters

| Parameter | Options | Description |
|-----------|---------|-------------|
| `project` | project1, project2, project3, all | Which project(s) to deploy |
| `action` | plan, apply, destroy | Terraform action to perform |
| `auto_approve` | true, false | Skip manual approval for apply/destroy |

### Example Deployments

**Plan Project 1:**
- Project: `project1`
- Action: `plan`
- Auto-approve: `false`

**Apply Project 2:**
- Project: `project2`
- Action: `apply`
- Auto-approve: `false`

**Deploy All Projects:**
- Project: `all`
- Action: `apply`
- Auto-approve: `false`

**Destroy Project 3:**
- Project: `project3`
- Action: `destroy`
- Auto-approve: `false`

## Workflow Features

### Security
- Azure authentication using service principal
- Secrets stored in GitHub Secrets
- No credentials in code
- Automatic logout after completion

### Validation
- Terraform format check
- Terraform validation
- Plan before apply
- Optional manual approval

### Outputs
- Terraform outputs captured as artifacts
- JSON format for easy parsing
- Available for download after workflow completion

### Flexibility
- Deploy individual projects or all at once
- Plan, apply, or destroy actions
- Auto-approve option for automated pipelines
- Conditional execution based on project selection

## Troubleshooting

### Authentication Issues

**Error**: `Error: Error building AzureRM Backend: Error validating AzureRM Backend credentials`

**Solution**: 
- Verify `AZURE_CREDENTIALS` secret is correctly formatted JSON
- Check service principal has Contributor role
- Ensure subscription ID is correct

### Storage Account Access

**Error**: `Error: storage account name not found`

**Solution**:
- Verify storage account name in secrets
- Check storage account exists in specified resource group
- Ensure service principal has access to storage account

### Backend Configuration

**Error**: `Error: container not found`

**Solution**:
- Verify container name in secrets
- Create container if it doesn't exist
- Check service principal has Storage Blob Data Contributor role

### Plan/Apply Failures

**Error**: Terraform plan or apply fails

**Solution**:
- Check Azure quotas and limits
- Verify VNet and subnets exist
- Ensure sufficient IP addresses in subnets
- Check service principal permissions

## Best Practices

### Security
1. **Rotate Secrets**: Regularly rotate service principal credentials
2. **Least Privilege**: Use specific roles instead of Owner
3. **Branch Protection**: Require approval for main branch
4. **Manual Approval**: Keep auto-approve disabled for production

### Workflow Management
1. **Environment Separation**: Use different workflows for dev/staging/prod
2. **Approval Gates**: Add environment approval for production
3. **Notifications**: Configure Slack/email notifications
4. **Monitoring**: Monitor workflow runs and failures

### Terraform State
1. **State Locking**: Ensure state locking is enabled
2. **Versioning**: Enable storage account versioning
3. **Backups**: Regular state file backups
4. **Drift Detection**: Regular drift detection runs

## Advanced Configuration

### Environment-Specific Workflows

Create separate workflows for different environments:

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy Staging
on:
  push:
    branches: [staging]
# ... similar structure with staging-specific secrets
```

### Approval Gates

Add environment protection rules:

1. Go to Repository Settings → Environments
2. Create environment: `production`
3. Add required reviewers
4. Add wait timer
5. Reference environment in workflow

### Conditional Deployment

Add conditions based on file changes:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'project1/**'
      - '.github/workflows/deploy-projects.yml'
```

## Cost Considerations

GitHub Actions costs:
- **Free tier**: 2,000 minutes/month for public repos
- **Private repos**: 2,000 minutes/month free, then $0.008/minute
- **Self-hosted runners**: No cost, but require maintenance

Terraform state storage:
- **Storage**: <$0.02 per GB/month
- **Operations**: Negligible
- **Total**: Typically <$1 per month

## Next Steps

1. Create Azure service principal
2. Set up storage account for state
3. Add secrets to GitHub repository
4. Test workflow with `plan` action
5. Review and approve plans
6. Deploy with `apply` action
7. Monitor and optimize as needed

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Service Principals](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)
- [Terraform State Management](https://www.terraform.io/cloud-docs/state)
