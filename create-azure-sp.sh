#!/bin/bash

# Script to create Azure Service Principal for GitHub Actions
# Run this script to generate the credentials needed for GitHub Secrets

echo "Creating Azure Service Principal for GitHub Actions..."
echo ""

# Check if user is logged in to Azure
echo "Checking Azure login status..."
if ! az account show > /dev/null 2>&1; then
    echo "You are not logged in to Azure. Please login first:"
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "Current subscription: $SUBSCRIPTION_ID"
echo "Current tenant: $TENANT_ID"
echo ""

# Prompt for service principal name
read -p "Enter service principal name [terraform-github-actions]: " SP_NAME
SP_NAME=${SP_NAME:-terraform-github-actions}

echo "Creating service principal: $SP_NAME"
echo ""

# Create service principal
echo "Creating service principal with Contributor role..."
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --json-auth)

echo "Service principal created successfully!"
echo ""

# Extract credentials
CLIENT_ID=$(echo $SP_JSON | jq -r .clientId)
CLIENT_SECRET=$(echo $SP_JSON | jq -r .clientSecret)
SUBSCRIPTION_ID=$(echo $SP_JSON | jq -r .subscriptionId)
TENANT_ID=$(echo $SP_JSON | jq -r .tenantId)

# Create GitHub-ready JSON
GITHUB_CREDENTIALS=$(cat <<EOF
{
  "clientId": "$CLIENT_ID",
  "clientSecret": "$CLIENT_SECRET",
  "subscriptionId": "$SUBSCRIPTION_ID",
  "tenantId": "$TENANT_ID"
}
EOF
)

echo "============================================"
echo "Add these secrets to your GitHub repository:"
echo "============================================"
echo ""
echo "Secret Name: AZURE_CREDENTIALS"
echo "Secret Value:"
echo "$GITHUB_CREDENTIALS"
echo ""
echo "============================================"
echo "Secret Name: AZURE_SUBSCRIPTION_ID"
echo "Secret Value: $SUBSCRIPTION_ID"
echo "============================================"
echo ""
echo "Additional secrets needed:"
echo "BACKEND_RESOURCE_GROUP_NAME: terraform-state-rg"
echo "BACKEND_STORAGE_ACCOUNT_NAME: your-storage-account-name"
echo "BACKEND_CONTAINER_NAME: tfstate"
echo ""
echo "IMPORTANT: Save the client secret securely. It won't be shown again!"
echo ""
echo "For detailed setup instructions, see GITHUB-ACTIONS-SETUP.md"
