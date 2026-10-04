# Project 1 Configuration
# Update these values with your actual configuration

resource_group_name     = "project5-web-rg"
resource_group_location = "eastus"

web_server_count = 6
vm_size          = "Standard_D2as_v4"
subnet_name      = "project-subnet"
vnet_name        = "my-vnet"

admin_username = "azureuser"
admin_password = "P@ssw0rd123!" # Change this to a secure password

environment = "production"
