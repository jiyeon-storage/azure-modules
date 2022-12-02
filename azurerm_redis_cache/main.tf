resource "azurerm_redis_cache" "this" {
  for_each = { for k, v in var.redis_cluster_config : k => v }

  name = each.value["redis_name"]

  resource_group_name           = var.resource_group_name
  location                      = var.location
  redis_version                 = 6 
  capacity                      = lookup(each.value, "capacity", 2)
  family                        = lookup(var.redis_family, each.value.sku_name)
  sku_name                      = lookup(each.value, "sku_name", "Premium")
  enable_non_ssl_port           = lookup(each.value, "enable_non_ssl_port", null)
  minimum_tls_version           = lookup(each.value, "minimum_tls_version", "1.2")
  private_static_ip_address     = lookup(each.value, "private_static_ip_address", null)
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", false)
  replicas_per_master           = lookup(each.value, "sku_name", "Premium") == "Premium" ? lookup(each.value, "replicas_per_master", 2) : null
  shard_count                   = lookup(each.value, "sku_name", "Premium") == "Premium" ? lookup(each.value, "shard_count", 2) : null
  subnet_id                     = lookup(each.value, "sku_name", "Premium") == "Premium" ? lookup(each.value, "subnet_id", null) : null
  #var.subnet_id : null
  zones = var.zones
  #zones = lookup(each.value, "zones", ["1", "2", "3"])
  #each.value["zones"]
  tags = merge({ "Name" = format("%s", each.key) }, local.default_tags)

  redis_configuration {
    enable_authentication           = lookup(var.redis_instance_config, "enable_authentication", true)
    maxfragmentationmemory_reserved = lookup(each.value, "sku_name", "Premium") == "Premium" || each.value["sku_name"] == "Premium" ? lookup(var.redis_instance_config, "maxfragmentationmemory_reserved", 2) : null
    maxmemory_delta                 = lookup(each.value, "sku_name", "Premium") == "Premium" || each.value["sku_name"] == "Premium" ? lookup(var.redis_instance_config, "maxmemory_delta", 2) : null
    maxmemory_policy                = lookup(var.redis_instance_config, "maxmemory_policy", "allkeys-lru")
    maxmemory_reserved              = lookup(each.value, "sku_name", "Premium") == "Premium" || each.value["sku_name"] == "Premium" ? lookup(var.redis_instance_config, "maxmemory_reserved", 2) : null
    notify_keyspace_events          = lookup(var.redis_instance_config, "notify_keyspace_events", "Ex")
    rdb_backup_enabled              = lookup(each.value, "sku_name", "Premium") == "Premium" && var.enable_data_persistence == true ? true : false
    rdb_backup_frequency            = lookup(each.value, "sku_name", "Premium") == "Premium" && var.enable_data_persistence == true ? var.data_persistence_backup_frequency : null
    rdb_backup_max_snapshot_count   = lookup(each.value, "sku_name", "Premium") == "Premium" && var.enable_data_persistence == true ? var.data_persistence_backup_max_snapshot_count : null
    rdb_storage_connection_string   = lookup(each.value, "sku_name", "Premium") == "Premium" && var.enable_data_persistence == true ? (var.storage_account_id == null ? azurerm_storage_account.this[0].primary_blob_connection_string : var.storage_account_primary_blob_connection_string) : null
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule != null ? [var.patch_schedule] : []
    content {
      day_of_week    = var.patch_schedule.day_of_week
      start_hour_utc = var.patch_schedule.start_hour_utc
    }
  }

  #lifecycle {
  #  # A bug in the Redis API where the original storage connection string isn't being returneds
  #  ignore_changes = [redis_configuration.0.rdb_storage_connection_string]
  #}
}

#----------------------------------------------------------------------
# Adding Firewall rules for Redis Cache Instance - Default is "false"
#----------------------------------------------------------------------
resource "azurerm_redis_firewall_rule" "this" {
  for_each = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}

  name = format("%s", each.key)

  redis_cache_name    = azurerm_redis_cache.this[0].name
  resource_group_name = var.resource_group_name
  start_ip            = each.value["start_ip"]
  end_ip              = each.value["end_ip"]
}

#----------------------------------------------------------------------
# Adding Logs for Redis Cache Instance - Default is "true"
#----------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  count = var.workspace_id == null ? 1 : 0

  name = format("%s%s-%s-logs", var.prefix, var.env, var.purpose)

  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_sku
  retention_in_days   = 30
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "true" 
#------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "audit" {
  name = lower("audit-${element([for n in azurerm_redis_cache.this : n.name], 0)}-diag")

  target_resource_id         = element([for i in azurerm_redis_cache.this : i.id], 0)
  log_analytics_workspace_id = var.workspace_id == null ? azurerm_log_analytics_workspace.this[0].id : var.workspace_id
  storage_account_id         = var.enable_data_persistence == true ? (var.storage_account_id == null ? azurerm_storage_account.this[0].id : var.storage_account_id) : null

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [metric]
  }
}
#----------------------------------------------------------------------
# Adding Storage for Redis Cache Instance - Default is "true"
#----------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  count = var.storage_account_id == null ? 1 : 0

  name = var.storage_account_name

  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s-", "backup-logs") }, local.default_tags)
}

## Private Link
resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s%s-%s-private-endpoint", var.prefix, var.env, var.purpose)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = merge({ "Name" = format("%s%s-%s-private-endpoint", var.prefix, var.env, var.purpose) }, local.default_tags)

  private_service_connection {
    name                           = "rediscache-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = element([for i in azurerm_redis_cache.this : i.id], 0)
    subresource_names              = ["redisCache"]
  }
}

data "azurerm_private_endpoint_connection" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.this[0].name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_redis_cache.this]
}

resource "azurerm_private_dns_zone" "dns_zone_1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
  tags                = merge({ "Name" = format("%s", "RedisCache-Private-DNS-Zone") }, local.default_tags)
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_1" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_1[0].name
  virtual_network_id    = var.vnet_id
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, local.default_tags)
}

resource "azurerm_private_dns_a_record" "a_record" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = element([for i in azurerm_redis_cache.this : i.name], 0)
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dns_zone_1[0].name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.this[0].private_service_connection[0].private_ip_address]
}
