output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.mixed_servers.resource_group_id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.mixed_servers.resource_group_name
}

output "linux_vm_ids" {
  description = "IDs of Linux VMs"
  value       = module.mixed_servers.linux_vm_ids
}

output "windows_vm_ids" {
  description = "IDs of Windows VMs"
  value       = module.mixed_servers.windows_vm_ids
}

output "all_vm_ids" {
  description = "IDs of all VMs"
  value       = module.mixed_servers.vm_ids
}

output "all_vm_names" {
  description = "Names of all VMs"
  value       = module.mixed_servers.vm_names
}

output "all_vm_private_ips" {
  description = "Private IP addresses of all VMs"
  value       = module.mixed_servers.vm_private_ips
}

output "all_nic_ids" {
  description = "Network interface IDs of all VMs"
  value       = module.mixed_servers.nic_ids
}
