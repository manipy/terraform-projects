# Terraform Backend Configuration for Azure Storage Account
# This stores the terraform.tfstate file in Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatepy"
    container_name       = "tfstate"
    key                  = "project1.tfstate"
  }
}
