# Terraform Backend Configuration for Azure Storage Account
# This stores the terraform.tfstate file in Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-rg"
    storage_account_name  = "terraformstate12345"  # Replace with your storage account name
    container_name        = "tfstate"              # Replace with your container name
    key                   = "project1.tfstate"
  }
}
