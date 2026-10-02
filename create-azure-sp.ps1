# PowerShell Script to create Azure Service Principal for GitHub Actions
# Run this script to generate the credentials needed for GitHub Secrets

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Creating Azure Service Principal for GitHub Actions..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
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

# Get current subscription
$SUBSCRIPTION_ID = $account.id
$TENANT_ID = $account.tenantId

Write-Host "Current subscription: $SUBSCRIPTION_ID"
Write-Host "Current tenant: $TENANT_ID"
Write-Host ""

# Prompt for service principal name
$SP_NAME = Read-Host "Enter service principal name [terraform-github-actions]"
if ([string]::IsNullOrWhiteSpace($SP_NAME)) {
    $SP_NAME = "terraform-github-actions"
}

Write-Host "Creating service principal: $SP_NAME"
Write-Host ""

# Create service principal
Write-Host "Creating service principal with Contributor role..." -ForegroundColor Yellow
try {
    $SP_JSON = az ad sp create-for-rbac `
      --name "$SP_NAME" `
      --role "Contributor" `
      --scopes "/subscriptions/$SUBSCRIPTION_ID" `
      --json-auth | ConvertFrom-Json

    Write-Host "✅ Service principal created successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creating service principal: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Extract credentials
$CLIENT_ID = $SP_JSON.clientId
$CLIENT_SECRET = $SP_JSON.clientSecret
$SUBSCRIPTION_ID = $SP_JSON.subscriptionId
$TENANT_ID = $SP_JSON.tenantId

# Create GitHub-ready JSON
$GITHUB_CREDENTIALS = @{
    clientId = $CLIENT_ID
    clientSecret = $CLIENT_SECRET
    subscriptionId = $SUBSCRIPTION_ID
    tenantId = $TENANT_ID
} | ConvertTo-Json

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Add these secrets to your GitHub repository:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Secret Name: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "Secret Value:" -ForegroundColor Yellow
Write-Host $GITHUB_CREDENTIALS
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Secret Name: AZURE_SUBSCRIPTION_ID" -ForegroundColor Cyan
Write-Host "Secret Value: $SUBSCRIPTION_ID" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Additional secrets needed (from storage account setup):" -ForegroundColor Yellow
Write-Host "BACKEND_RESOURCE_GROUP_NAME: terraform-state-rg"
Write-Host "BACKEND_STORAGE_ACCOUNT_NAME: your-storage-account-name"
Write-Host "BACKEND_CONTAINER_NAME: tfstate"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "IMPORTANT:" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host "⚠️  Save the client secret securely. It won't be shown again!"
Write-Host "⚠️  Store the AZURE_CREDENTIALS JSON securely - it contains sensitive data"
Write-Host "⚠️  For added security, consider using Azure Key Vault to store credentials"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "1. Copy the AZURE_CREDENTIALS JSON above"
Write-Host "2. Add it as a secret in your GitHub repository"
Write-Host "3. Add AZURE_SUBSCRIPTION_ID as a separate secret"
Write-Host "4. Add the storage account secrets from the previous step"
Write-Host "5. Follow the complete setup in DEPLOYMENT-PREREQUISITES.md"
Write-Host ""
Write-Host "For detailed setup instructions, see DEPLOYMENT-PREREQUISITES.md" -ForegroundColor Cyan
