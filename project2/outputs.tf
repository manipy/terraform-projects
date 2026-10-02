output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.app_servers.resource_group_id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.app_servers.resource_group_name
}

output "app_server_ids" {
  description = "IDs of the application servers"
  value       = module.app_servers.windows_vm_ids
}

output "app_server_names" {
  description = "Names of the application servers"
  value       = module.app_servers.vm_names
}

output "app_server_private_ips" {
  description = "Private IP addresses of the application servers"
  value       = module.app_servers.vm_private_ips
}

output "app_server_nic_ids" {
  description = "Network interface IDs of the application servers"
  value       = module.app_servers.nic_ids
}
