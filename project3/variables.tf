variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
}

variable "linux_web_count" {
  description = "Number of Linux web servers to create"
  type        = number
  default     = 2
}

variable "windows_db_count" {
  description = "Number of Windows database servers to create"
  type        = number
  default     = 1
}

variable "linux_vm_size" {
  description = "VM size for Linux web servers"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "windows_vm_size" {
  description = "VM size for Windows database servers"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "linux_subnet_name" {
  description = "Name of the subnet for Linux web servers"
  type        = string
}

variable "windows_subnet_name" {
  description = "Name of the subnet for Windows database servers"
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

variable "windows_version" {
  description = "Windows Server version (2019-Datacenter or 2022-Datacenter)"
  type        = string
  default     = "2022-Datacenter"
}
