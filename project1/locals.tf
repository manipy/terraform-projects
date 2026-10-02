locals {
  # Common web server configuration
  common_web_config = {
    vm_size               = var.vm_size
    subnet_name           = var.subnet_name
    vnet_name             = var.vnet_name
    private_ip_allocation = "Dynamic"
    admin_username        = var.admin_username
    admin_password        = var.admin_password
    os_type               = "linux"
    os_disk_storage_type  = "Premium_LRS"
    os_disk_size_gb       = 30
    os_publisher          = "Canonical"
    os_offer              = "0001-com-ubuntu-server-jammy"
    os_sku                = "22_04-lts-gen2"
    os_version            = "latest"
    custom_script         = "sudo apt-get update && sudo apt-get install -y nginx && sudo systemctl start nginx"
  }

  # Generate web server configurations based on count
  web_server_vms = {
    for i in range(var.web_server_count) : "webserver-${format("%02d", i + 1)}" => {}
  }

  # Common tags
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "PlatformTeam"
  }
}
