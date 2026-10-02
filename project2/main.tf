# Project 2 - Windows Application Infrastructure
# This module will create Windows application servers using the AVM module from git repository

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "app_servers" {
  source = "git::https://github.com/your-org/terraform-modules.git//avm?ref=main"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    for vm_name, vm_config in local.app_server_vms : vm_name => local.common_app_config
  }

  tags = merge(local.common_tags, {
    Project     = "Project2"
    Application = "WindowsApplication"
    Tier        = "Backend"
  })
}
