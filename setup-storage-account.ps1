# PowerShell Script to create Azure Storage Account for Terraform State Management
# Run this script before deploying any Terraform projects

# Configuration
$RESOURCE_GROUP_NAME = "terraform-state-rg"
$STORAGE_ACCOUNT_NAME = "terraformstate" + (Get-Random -Minimum 10000 -Maximum 99999)  # Random suffix for uniqueness
$CONTAINER_NAME = "tfstate"
$LOCATION = "eastus"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Creating Terraform State Storage Account..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Resource Group: $RESOURCE_GROUP_NAME"
Write-Host "Storage Account: $STORAGE_ACCOUNT_NAME"
Write-Host "Container: $CONTAINER_NAME"
Write-Host "Location: $LOCATION"
Write-Host ""

# Check if user is logged in to Azure
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show | ConvertFrom-Json
    if (-not $account) {
        Write-Host "You are not logged in to Azure. Please login first:" -ForegroundColor Red
        az login
        $account = az account show | ConvertFrom-Json
    }
    Write-Host "✅ Logged in to Azure as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "You are not logged in to Azure. Please login first:" -ForegroundColor Red
    az login
    $account = az account show | ConvertFrom-Json
}

Write-Host ""

# Create Resource Group
Write-Host "Step 1: Creating Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $RESOURCE_GROUP_NAME
if ($rgExists -eq "true") {
    Write-Host "Resource group already exists: $RESOURCE_GROUP_NAME" -ForegroundColor Yellow
} else {
    az group create `
      --name $RESOURCE_GROUP_NAME `
      --location $LOCATION
    Write-Host "✅ Resource group created: $RESOURCE_GROUP_NAME" -ForegroundColor Green
}

# Create Storage Account
Write-Host "Step 2: Creating Storage Account..." -ForegroundColor Yellow
try {
    az storage account create `
      --resource-group $RESOURCE_GROUP_NAME `
      --name $STORAGE_ACCOUNT_NAME `
      --sku Standard_LRS `
      --encryption-services blob `
      --https-only true
    Write-Host "✅ Storage account created: $STORAGE_ACCOUNT_NAME" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creating storage account. It might already exist or name might be taken." -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Get Storage Account Key
Write-Host "Step 3: Getting Storage Account Key..." -ForegroundColor Yellow
$STORAGE_ACCOUNT_KEY = az storage account keys list `
  --resource-group $RESOURCE_GROUP_NAME `
  --account-name $STORAGE_ACCOUNT_NAME `
  --query '[0].value' -o tsv

if (-not $STORAGE_ACCOUNT_KEY) {
    Write-Host "❌ Error getting storage account key" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Storage account key retrieved" -ForegroundColor Green

# Create Container
Write-Host "Step 4: Creating Container..." -ForegroundColor Yellow
try {
    az storage container create `
      --name $CONTAINER_NAME `
      --account-name $STORAGE_ACCOUNT_NAME `
      --account-key $STORAGE_ACCOUNT_KEY
    Write-Host "✅ Container created: $CONTAINER_NAME" -ForegroundColor Green
} catch {
    Write-Host "Container might already exist. Continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ Storage Account setup completed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Add these values to your GitHub Secrets:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Secret Name: BACKEND_RESOURCE_GROUP_NAME" -ForegroundColor Yellow
Write-Host "Secret Value: $RESOURCE_GROUP_NAME" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: BACKEND_STORAGE_ACCOUNT_NAME" -ForegroundColor Yellow
Write-Host "Secret Value: $STORAGE_ACCOUNT_NAME" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: BACKEND_CONTAINER_NAME" -ForegroundColor Yellow
Write-Host "Secret Value: $CONTAINER_NAME" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "1. Update backend.tf files in each project with these values"
Write-Host "2. Add the above secrets to your GitHub repository"
Write-Host "3. Run create-azure-sp.ps1 to create service principal"
Write-Host "4. Follow the instructions in DEPLOYMENT-PREREQUISITES.md"
Write-Host ""
Write-Host "For detailed setup instructions, see DEPLOYMENT-PREREQUISITES.md" -ForegroundColor Cyan
