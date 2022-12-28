resource "azurerm_virtual_network" "this" {
  name                = format("%s%s-%s-vnet", var.prefix, var.env, var.purpose)
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.cidrs
  dns_servers         = var.dns_servers
  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-vnet", var.prefix, var.env, var.purpose)
  })
}

resource "azurerm_subnet" "this" {
  for_each = { for k, v in var.subnet_cidrs : k => v }

  name = format("%s%s-%s-%s-subnet", var.prefix, var.env, var.purpose, each.key)

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value
  service_endpoints    = lookup(var.subnet_service_endpoints, each.key, null)
  #enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, each.key, false)
  #enforce_private_link_service_network_policies = lookup(var.subnet_enforce_private_link_service_network_policies, each.key, false)

  dynamic "delegation" {
    for_each = lookup(var.subnet_delegation, each.key, {})
    content {
      name = delegation.key
      service_delegation {
        name    = lookup(delegation.value, "service_name")
        actions = lookup(delegation.value, "service_actions", [])
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnet_cidrs : k => v }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = var.route_tables_ids == null ? {} : var.route_tables_ids
  route_table_id = each.value
  subnet_id      = azurerm_subnet.this[each.key].id
}

# policy modify 기능 추가 필요 
resource "azurerm_network_security_group" "nsg" {
  for_each = { for k, v in var.subnet_cidrs : k => v }

  name = format("%s%s-%s-%s-nsg", var.prefix, var.env, var.purpose, each.key)

  location            = var.location
  resource_group_name = var.resource_group_name
  tags = merge(local.default_tags, {
    subnet_type = format("%s%s-%s-%s-nsg", var.prefix, var.env, var.purpose, each.key)
  })
}
