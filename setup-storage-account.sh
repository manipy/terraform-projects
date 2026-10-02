#!/bin/bash

# Script to create Azure Storage Account for Terraform State Management
# Run this script before deploying any Terraform projects

# Configuration
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="terraformstate$(date +%s | head -c 6)"  # Random suffix for uniqueness
CONTAINER_NAME="tfstate"
LOCATION="eastus"

echo "Creating Terraform State Storage Account..."
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo "Location: $LOCATION"
echo ""

# Create Resource Group
echo "Step 1: Creating Resource Group..."
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION

# Create Storage Account
echo "Step 2: Creating Storage Account..."
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true

# Get Storage Account Key
echo "Step 3: Getting Storage Account Key..."
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' -o tsv)

# Create Container
echo "Step 4: Creating Container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $STORAGE_ACCOUNT_KEY

echo ""
echo "✅ Storage Account setup completed successfully!"
echo ""
echo "IMPORTANT: Update the backend.tf files in each project with these values:"
echo "  resource_group_name: $RESOURCE_GROUP_NAME"
echo "  storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "  container_name: $CONTAINER_NAME"
echo ""
echo "Storage Account Key (save this securely):"
echo "  $STORAGE_ACCOUNT_KEY"
echo ""
echo "For added security, consider using Azure Key Vault to store the storage account key."
