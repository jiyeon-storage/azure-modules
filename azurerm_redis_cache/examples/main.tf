resource "azurerm_resource_group" "rg" {
  name     = "jay-test-rg"
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "jay-test-vnet"
  location            = local.location
  address_space       = ["10.100.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "jay-test-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.100.10.0/24"]
}

module "this" {
  source = "../"

  # Tags 
  prefix  = local.prefix
  env     = local.env
  team    = local.team
  purpose = local.purpose

  # resource group & location
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  vnet_id             = azurerm_virtual_network.vnet.id

  # Configuration to provision a Standard Redis Cache
  # Specify `shard_count` to create on the Redis Cluster
  # Add patch_schedle to this object to enable redis patching schedule
  redis_cluster_config = [
    {
      redis_name = "test-redis"
      sku_name   = "Premium"
      capacity   = 2
    }
  ]

  # MEMORY MANAGEMENT
  # Azure Cache for Redis instances are configured with the following default Redis configuration values:
  redis_instance_config = {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }

  # PACTCH WINDOW
  patch_schedule = {
    day_of_week    = "Tuesday"
    start_hour_utc = 10
  }
  # SNAPSHOTTING - Redis data backup
  # Data persistence doesn't work if `shard_count` is specified. i.e. Cluster enabled.
  enable_data_persistence                    = true
  data_persistence_backup_frequency          = 60
  data_persistence_backup_max_snapshot_count = 1

  # Configure virtual network support for Azure Cache for Redis instance
  # Only works with "Premium" SKU tier
  # ex) data.remote_backend.vnet.output.db_subnet.id
  subnet_id = azurerm_subnet.subnet.id

  #Azure Cache for Redis firewall filter rules are used to provide specific source IP access. 
  # Azure Redis Cache access is determined based on start and end IP address range specified. 
  # As a rule, only specific IP addresses should be granted access, and all others denied.
  # "name" (ex. azure_to_azure or desktop_ip) may only contain alphanumeric characters and underscores
  firewall_rules = {
    "access_to_azure" = {
      start_ip = "10.0.0.0"
      end_ip   = "10.0.1.255"
    },
    "desktop_ip" = {
      start_ip = "111.111.111.111"
      end_ip   = "111.111.111.111"
    }
  }

  storage_account_name = "teststroage"


  # redis info
  enable_private_endpoint = true
}
