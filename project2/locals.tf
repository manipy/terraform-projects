locals {
  # Common Windows application server configuration
  common_app_config = {
    vm_size                = var.vm_size
    subnet_name            = var.subnet_name
    vnet_name              = var.vnet_name
    private_ip_allocation  = "Dynamic"
    admin_username         = var.admin_username
    admin_password         = var.admin_password
    os_type                = "windows"
    os_disk_storage_type   = "Premium_LRS"
    os_disk_size_gb        = 127
    os_publisher           = "MicrosoftWindowsServer"
    os_offer               = "WindowsServer"
    os_sku                 = var.windows_version
    os_version             = "latest"
    custom_script          = "Install-WindowsFeature -name Web-Server -IncludeManagementTools; Install-WindowsFeature -name NET-Framework-45-Core -IncludeManagementTools"
  }

  # Generate application server configurations based on count
  app_server_vms = {
    for i in range(var.app_server_count) : "win-appserver-${format("%02d", i + 1)}" => {}
  }

  # Common tags
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "WindowsTeam"
  }
}
