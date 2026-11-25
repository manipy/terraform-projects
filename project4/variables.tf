variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
}

variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for web servers"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "subnet_name" {
  description = "Name of the subnet for web servers"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}
