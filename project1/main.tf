# Project 1 - Web Application Infrastructure
# This module will create Linux web servers using the AVM module from git repository

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

module "web_servers" {
  source = "git::https://github.com/manipy/terraform_modules.git//avm?ref=main"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    for vm_name, vm_config in local.web_server_vms : vm_name => local.common_web_config
  }

  tags = merge(local.common_tags, {
    Project     = "Project1"
    Application = "WebApplication"
    Tier        = "Frontend"
  })
}
