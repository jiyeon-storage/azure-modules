data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Manages the Subnet
resource "azurerm_subnet" "this" {
  address_prefixes     = var.subnet_address_prefixes
  name                 = format("%s%s-%s-db-subnet",local.prefix, local.env, local.purpose)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#----------------------------------------------------------------
# Adding  MySQL Flexible Server creation and settings - Default is "True"
#-----------------------------------------------------------------
resource "azurerm_mysql_flexible_server" "main" {
  name                              = format("%s", var.mysqlserver_name)
  resource_group_name               = var.resource_group_name
  location                          = var.location
  zone                              = var.mysqlserver_settings.zone
  administrator_login               = var.mysqlserver_settings.administrator_login
  administrator_password            = var.mysqlserver_settings.administrator_password
  sku_name                          = var.mysqlserver_settings.sku_name
  version                           = var.mysqlserver_settings.version
  backup_retention_days             = var.mysqlserver_settings.backup_retention_days
  geo_redundant_backup_enabled      = var.mysqlserver_settings.geo_redundant_backup_enabled
  delegated_subnet_id               = azurerm_subnet.this.id
  private_dns_zone_id               = azurerm_private_dns_zone.this[0].id
  create_mode                       = var.create_mode
  point_in_time_restore_time_in_utc = var.create_mode == "PointInTimeRestore" ? var.point_in_time_restore_time_in_utc : null
  tags                              = merge({ "Name" = format("%s",var.mysqlserver_name) }, var.tags, )
  depends_on                        = [azurerm_private_dns_zone_virtual_network_link.this]

  high_availability {
    mode                      = var.mysqlserver_settings.mode
    standby_availability_zone = var.mysqlserver_settings.standby_availability_zone
  }
  maintenance_window {
    day_of_week  = var.mysqlserver_settings.maintenance_window_day_of_week
    start_hour   = var.mysqlserver_settings.maintenance_window_start_hour
    start_minute = var.mysqlserver_settings.maintenance_window_start_minute
  }
  storage {
    iops    = var.mysqlserver_settings.iops
    size_gb = var.mysqlserver_settings.size_gb
    auto_grow_enabled = var.mysqlserver_settings.auto_grow_enabled
  }
}

#------------------------------------------------------------
# Adding  MySQL Flexible Server Database - Default is "true"
#------------------------------------------------------------
resource "azurerm_mysql_flexible_database" "this" {
  name                = var.mysqlserver_settings.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = var.mysqlserver_settings.charset
  collation           = var.mysqlserver_settings.collation
}

#---------------------------------------------------------
# Storage Account to keep Audit logs - Default is "false"
#----------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = var.storage_account_kind
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_type
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

#------------------------------------------------------------
# Adding  MySQL Server Parameters - Default is "false"
#------------------------------------------------------------
resource "azurerm_mysql_flexible_server_configuration" "this" {
  for_each            = var.mysql_configuration != null ? { for k, v in var.mysql_configuration : k => v if v != null } : {}
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = each.value
}

#---------------------------------------------------------
# Private Link for SQL Server - Default is "false" 
#---------------------------------------------------------
resource "azurerm_private_dns_zone" "this" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = format("%s%s-%s.mysql.database.azure.com",local.prefix, local.env, local.purpose)
  resource_group_name = var.resource_group_name
  tags                = merge({ "Name" = format("%s%s-%s.mysql.database.azure.com",local.prefix, local.env, local.purpose) }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = format("%s%s-%s-pri-zone-link",local.prefix, local.env, local.purpose)
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[0].name
  virtual_network_id    = var.vnet
  tags                  = merge({ "Name" = format("%s%s-%s-pri-zone-link",local.prefix, local.env, local.purpose) }, var.tags, )
}
# resource "azurerm_private_endpoint" "this" {
#   count               = var.enable_private_endpoint ? 1 : 0
#   name                = format("%s-private-endpoint", var.mysqlserver_name)
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id
#   tags                = merge({ "Name" = format("%s-private-endpoint", var.mysqlserver_name) }, var.tags, )

#   private_service_connection {
#     name                           = "sqldbprivatelink"
#     is_manual_connection           = false
#     private_connection_resource_id = azurerm_mysql_flexible_server.main.id
#     subresource_names              = ["mysqlServer"]
#   }
# }

# data "azurerm_private_endpoint_connection" "this" {
#   count               = var.enable_private_endpoint ? 1 : 0
#   name                = azurerm_private_endpoint.this.0.name
#   resource_group_name = var.resource_group_name
#   depends_on          = [azurerm_mysql_flexible_server.main]
# }

# resource "azurerm_private_dns_a_record" "this" {
#   count               = var.enable_private_endpoint ? 1 : 0
#   name                = azurerm_mysql_flexible_server.main.name
#   zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.this.0.name : var.existing_private_dns_zone
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [data.azurerm_private_endpoint_connection.this.0.private_service_connection.0.private_ip_address]
# }

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
#------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  count                      = var.log_analytics_workspace_name != null ? 1 : 0
  name                       = lower("extaudit-${var.mysqlserver_name}-diag")
  target_resource_id         = azurerm_mysql_flexible_server.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logws.0.id
  storage_account_id         = azurerm_storage_account.this.id

  dynamic "log" {
    for_each = var.extaudit_diag_logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}