## vnet
output "vnet_id" {
  description = "vnet id"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "vnet name"
  value       = azurerm_virtual_network.this.name
}

output "vnet" {
  description = "vnet data object"
  value       = azurerm_virtual_network.this
}

## subnet
output "subnet_ids" {
  description = "subnet id"
  value = { for k, v in azurerm_subnet.this :
    k => {
      id = v.id
    }
  }
}

output "subnet_names" {
  description = "subnet name"
  value = { for k, v in azurerm_subnet.this :
    k => {
      name = v.name
    }
  }
}

output "network_security_group_ids" {
  description = "network security group id"
  value = { for k, v in azurerm_network_security_group.nsg :
    k => {
      id = v.id
    }
  }
}

output "network_security_group_names" {
  description = "network security group name"
  value = { for k, v in azurerm_network_security_group.nsg :
    k => {
      name = v.name
    }
  }
}

output "subnet" {
  description = "subnet data object"
  value       = azurerm_subnet.this
}
