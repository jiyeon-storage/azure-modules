## vnet 
output "vnet_id" {
  description = "vnet id"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "vnet name"
  value       = module.vnet.vnet_name
}

output "vnet" {
  description = "vnet name"
  value       = module.vnet.vnet
}

## subnet
output "subnet_ids" {
  description = "subnet id"
  value       = module.vnet.subnet_ids
}

output "subnet_names" {
  description = "subnet name"
  value       = module.vnet.subnet_names
}

output "network_security_group_ids" {
  description = "network security group id"
  value       = module.vnet.network_security_group_ids
}

output "network_security_group_names" {
  description = "network security group name"
  value       = module.vnet.network_security_group_names
}

output "subnet" {
  description = "subnet data object"
  value       = module.vnet.subnet
}
