resource "azurerm_resource_group" "this" {
  name = "jay-test-rg"
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name                = "jay-test-vnet"
  location            = local.location
  address_space       = ["10.100.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_storage_account" "sc" {
  name                      = "jaytestcs"
  resource_group_name       = azurerm_resource_group.this.name
  location                  = local.location
  account_tier              = "Standard"
  account_replication_type  = "RAGRS"
}

module "mysql-db" {
  source    = "../"
  prefix    = local.prefix
  env       = local.env
  team      = local.team
  purpose   = local.purpose
  vnet = azurerm_virtual_network.this.id
  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  resource_group_name     = azurerm_resource_group.this.name
  location                = azurerm_resource_group.this.location
  subnet_address_prefixes = ["10.100.2.0/24"]


  # MySQL Server and Database settings
  mysqlserver_name = format("%s%s-%s-mysqldb",local.prefix, local.env, local.purpose)

  mysqlserver_settings = {
    sku_name  = "GP_Standard_D2ds_v4"
    size_gb   = 5120
    iops      = 360
    version   = "8.0.21"
    mode       = "ZoneRedundant"
    administrator_login = "sqladmin"
    administrator_password = "****************"
    # Database name, charset and collection arguments  
    database_name = "demomysqldb"
    charset       = "utf8"
    collation     = "utf8_unicode_ci"
    # Storage Profile and other optional arguments
    auto_grow_enabled                 = true
    backup_retention_days             = 7
    geo_redundant_backup_enabled      = false
    standby_availability_zone         = 1
    maintenance_window_day_of_week    = 0
    maintenance_window_start_hour     = 0
    maintenance_window_start_minute   = 0
  }

  # MySQL Server Parameters
  # For more information: https://docs.microsoft.com/en-us/azure/mysql/concepts-server-parameters
  mysql_configuration = {
    time_zone = "US/Pacific"
  }

  # Use Virtual Network service endpoints and rules for Azure Database for MySQL
  #subnet_id = azurerm_subnet.this.id

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.mysql.database.azure.com` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  enable_private_endpoint       = true
  virtual_network_name          = azurerm_virtual_network.this.name
  #private_subnet_address_prefix = azurerm_subnet.this.address_prefixes
  #  existing_private_dns_zone     = "demo.example.com"

  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  # enable_threat_detection_policy = true
  # log_retention_days             = 30
  # email_addresses_for_alerts     = ["user@example.com", "firstname.lastname@example.com"]

  # (Optional) To enable Azure Monitoring for Azure MySQL database
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  storage_account_name = azurerm_storage_account.sc.name
  storage_account_id = azurerm_storage_account.sc.id
  #log_analytics_workspace_name = "loganalytics-we-sharedtest2"
  
  tags = {
    prefix    = local.prefix
    env       = local.env
    team      = local.team
    purpose   = local.purpose
  }
}
