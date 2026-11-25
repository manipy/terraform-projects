output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.web_servers.resource_group_id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.web_servers.resource_group_name
}

output "web_server_ids" {
  description = "IDs of the web servers"
  value       = module.web_servers.linux_vm_ids
}

output "web_server_names" {
  description = "Names of the web servers"
  value       = module.web_servers.vm_names
}

output "web_server_private_ips" {
  description = "Private IP addresses of the web servers"
  value       = module.web_servers.vm_private_ips
}

output "web_server_nic_ids" {
  description = "Network interface IDs of the web servers"
  value       = module.web_servers.nic_ids
}
