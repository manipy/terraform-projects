# Project 3 - Mixed Environment Infrastructure
# This module will create both Linux and Windows VMs using the AVM module from git repository

module "mixed_servers" {
  source = "git::https://github.com/manipy/terraform_modules.git//avm?ref=main"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = merge(
    # Linux web servers
    {
      for vm_name, vm_config in local.linux_web_vms : vm_name => merge(local.common_linux_config, vm_config)
    },
    # Windows database servers
    {
      for vm_name, vm_config in local.windows_db_vms : vm_name => merge(local.common_windows_config, vm_config)
    }
  )

  tags = merge(local.common_tags, {
    Project     = "Project3"
    Application = "MixedEnvironment"
    Tier        = "MultiTier"
  })
}
