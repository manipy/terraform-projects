# Project 3 Configuration
# Update these values with your actual configuration

resource_group_name     = "project3-mixed-rg"
resource_group_location = "eastus"

linux_web_count     = 2
windows_db_count    = 1
linux_vm_size       = "Standard_DS1_v2"
windows_vm_size     = "Standard_DS3_v2"
linux_subnet_name   = "web-subnet"
windows_subnet_name = "db-subnet"
vnet_name           = "my-vnet"

admin_username = "azureuser"
admin_password = "P@ssw0rd123!" # Change this to a secure password

environment     = "production"
windows_version = "2022-Datacenter"
