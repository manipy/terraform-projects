locals {
  # Common Linux web server configuration
  common_linux_config = {
    vm_size                = var.linux_vm_size
    vnet_name              = var.vnet_name
    private_ip_allocation  = "Dynamic"
    admin_username         = var.admin_username
    admin_password         = var.admin_password
    os_type                = "linux"
    os_disk_storage_type   = "Premium_LRS"
    os_disk_size_gb        = 30
    os_publisher           = "Canonical"
    os_offer               = "0001-com-ubuntu-server-jammy"
    os_sku                 = "22_04-lts-gen2"
    os_version             = "latest"
    custom_script          = "sudo apt-get update && sudo apt-get install -y nginx docker.io && sudo systemctl start nginx"
  }

  # Common Windows database server configuration
  common_windows_config = {
    vm_size                = var.windows_vm_size
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
    custom_script          = "Install-WindowsFeature -name NET-Framework-45-Core -IncludeManagementTools; Install-WindowsFeature -name Web-Server -IncludeManagementTools"
  }

  # Generate Linux web server configurations
  linux_web_vms = {
    for i in range(var.linux_web_count) : "linux-web-${format("%02d", i + 1)}" => {
      subnet_name = var.linux_subnet_name
    }
  }

  # Generate Windows database server configurations
  windows_db_vms = {
    for i in range(var.windows_db_count) : "win-db-${format("%02d", i + 1)}" => {
      subnet_name = var.windows_subnet_name
    }
  }

  # Common tags
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOpsTeam"
  }
}
