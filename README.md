# Terraform Projects

This directory contains multiple Terraform projects that invoke the AVM (Azure Virtual Machine) module from a git repository.

## Structure

```
terraform-projects/
├── project1/          # Linux web servers
│   ├── main.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── terraform.tfvars.example
├── project2/          # Windows application servers
│   ├── main.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── terraform.tfvars.example
├── project3/          # Mixed Linux and Windows environment
│   ├── main.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── terraform.tfvars.example
├── setup-storage-account.sh    # Bash script to create storage account
├── setup-storage-account.ps1  # PowerShell script to create storage account
├── create-azure-sp.sh         # Bash script to create Azure service principal
├── create-azure-sp.ps1        # PowerShell script to create Azure service principal
├── .github/
│   └── workflows/
│       └── deploy-projects.yml  # GitHub Actions workflow
├── .gitignore
├── GITHUB-ACTIONS-SETUP.md    # GitHub Actions setup guide
├── STORAGE-ACCOUNT-SETUP.md   # Storage account setup guide
└── README.md
```

## Project Descriptions

### Project 1 - Linux Web Servers
- Creates Linux web servers (Ubuntu 22.04)
- Uses Nginx for web serving
- Deploys to web subnet
- Configurable number of servers

### Project 2 - Windows Application Servers
- Creates Windows application servers (Windows Server 2019/2022)
- Includes IIS and .NET Framework
- Deploys to application subnet
- Configurable number of servers

### Project 3 - Mixed Environment
- Creates both Linux web servers and Windows database servers
- Multi-tier deployment scenario
- Uses different subnets for different server types
- Demonstrates mixed OS environment

## Module Source

All projects reference the AVM module from a git repository:

```hcl
source = "git::https://github.com/your-org/terraform-modules.git//avm?ref=main"
```

**Important**: Update the git repository URL in each `main.tf` file to point to your actual repository before deployment.

## Prerequisites

1. **Git Repository**: The AVM module must be pushed to a git repository
2. **Azure Credentials**: Authenticate with Azure using CLI or service principal
3. **Existing VNet**: Ensure the specified virtual network and subnets exist
4. **Terraform**: Install Terraform >= 1.0.0
5. **Storage Account**: Azure Storage Account for Terraform state management (optional but recommended)

## Setup Instructions

### Quick Start Guide

For complete setup instructions, see **[DEPLOYMENT-PREREQUISITES.md](DEPLOYMENT-PREREQUISITES.md)** - this contains all prerequisites, step-by-step setup commands, and GitHub Secrets configuration.

### 0. Setup Storage Account (Optional but Recommended)

Before deploying, set up an Azure Storage Account to store Terraform state files:

**Using PowerShell:**
```powershell
.\setup-storage-account.ps1
```

**Using Bash:**
```bash
chmod +x setup-storage-account.sh
./setup-storage-account.sh
```

The script will:
- Create a resource group for state management
- Create a storage account
- Create a container for state files
- Display the connection details

Update the `backend.tf` files in each project with the values returned by the script.

### 1. Update Module Source

Before deploying, update the git repository URL in each project's `main.tf`:

```hcl
source = "git::https://github.com/YOUR-ORG/YOUR-REPO.git//avm?ref=main"
```

### 2. Configure Variables

Update the `terraform.tfvars` file in each project with your specific values:

- Resource group name and location
- Virtual network and subnet names
- Admin credentials (use secure passwords)
- IP addressing
- VM sizes and counts

### 3. Deploy Individual Projects

Navigate to each project directory and run:

```bash
cd terraform-projects/project1
terraform init
terraform plan
terraform apply
```

**Note**: When using remote backend, Terraform will authenticate using your Azure CLI credentials. Make sure you're logged in:
```bash
az login
```

### 4. Deploy All Projects

To deploy all projects sequentially:

```bash
# Project 1
cd terraform-projects/project1
terraform init
terraform apply

# Project 2
cd ../project2
terraform init
terraform apply

# Project 3
cd ../project3
terraform init
terraform apply
```

## Variables Reference

### Common Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `resource_group_name` | Name of resource group to create | `project1-web-rg` |
| `resource_group_location` | Azure region | `eastus` |
| `vnet_name` | Existing virtual network name | `my-vnet` |
| `subnet_name` | Existing subnet name (or linux_subnet_name/windows_subnet_name) | `web-subnet` |
| `admin_username` | VM admin username | `azureuser` |
| `admin_password` | VM admin password | `SecurePassword123!` |
| `environment` | Environment tag | `production` |

### Project-Specific Variables

Each project has additional variables for:
- Server count (web_server_count, app_server_count, etc.)
- VM sizes (vm_size, linux_vm_size, windows_vm_size)
- Subnet names (subnet_name, linux_subnet_name, etc.)
- Virtual network name (vnet_name)
- Windows version (windows_version)

## Outputs

Each project outputs:
- Resource group ID and name
- VM IDs and names
- Private IP addresses
- Network interface IDs

## Security Best Practices

1. **Credentials**: Never commit actual passwords to git. Use environment variables or secret management:
   ```bash
   export TF_VAR_admin_password="YourSecurePassword"
   ```

2. **State Management**: Using Azure Storage Account backend (configured in backend.tf) provides:
   - State file encryption
   - Team collaboration
   - State locking
   - Versioning

3. **Storage Account Access**: For enhanced security, configure the backend with environment variables:
   ```bash
   export ARM_ACCESS_KEY="your-storage-account-key"
   ```
   Or use managed identity for authentication.

4. **Network Security**: Apply Network Security Groups to restrict traffic

5. **Key Vault**: Consider using Azure Key Vault for credential management

## Customization

### Adding New Projects

To add a new project:

1. Create a new directory: `mkdir terraform-projects/project4`
2. Copy the template files from an existing project
3. Update `main.tf` with your module configuration
4. Modify `variables.tf` for your specific needs
5. Update `locals.tf` for your configuration logic
6. Configure `terraform.tfvars` with your values
7. Define outputs in `outputs.tf`

### Modifying Existing Projects

Each project can be customized by:
- Changing VM configurations in `locals.tf`
- Adding/removing variables in `variables.tf`
- Updating the module source in `main.tf`
- Modifying IP allocation logic in `locals.tf`

## Troubleshooting

### Module Not Found
- Ensure the git repository URL is correct
- Check that the repository contains the `avm` module
- Verify you have access to the git repository

### Authentication Issues
- Ensure Azure CLI is authenticated: `az login`
- Check service principal permissions if using SPN authentication

### Network Issues
- Verify the specified VNet and subnets exist
- Ensure subnet has available capacity for dynamic IP allocation

## Git Repository Structure

The git repository should contain the AVM module with this structure:

```
terraform-modules/
└── avm/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── providers.tf
    ├── data.tf
    └── README.md
```

## Next Steps

1. Push the `terraform_modules/avm` directory to your git repository
2. Update the module source URLs in all project `main.tf` files
3. Test deployment with a single project first
4. Deploy remaining projects as needed
5. Set up CI/CD pipelines for automated deployments
