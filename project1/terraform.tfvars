# Project 1 Configuration
# Update these values with your actual configuration

resource_group_name     = "project1-web-rg"
resource_group_location = "eastus"

web_server_count = 1
vm_size          = "Standard_DS1_v2"
subnet_name      = "web-subnet"
vnet_name        = "my-vnet"

admin_username = "azureuser"
# admin_password = "P@ssw0rd123!" # Change this to a secure password

environment = "production"
