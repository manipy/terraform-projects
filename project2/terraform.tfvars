# Project 2 Configuration
# Update these values with your actual configuration

resource_group_name     = "project2-app-rg"
resource_group_location = "eastus"

app_server_count = 2
vm_size          = "Standard_DS2_v2"
subnet_name      = "app-subnet"
vnet_name        = "my-vnet"

admin_username = "azureuser"
admin_password = "P@ssw0rd123!" # Change this to a secure password

environment     = "production"
windows_version = "2019-Datacenter"
