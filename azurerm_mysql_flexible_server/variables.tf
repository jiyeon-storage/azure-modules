variable "resource_group_name" {
  type        = string
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "vnet" {
  type        = string
  description = "The resource of the vnet"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "The name of log analytics workspace name"
  default     = null
}

variable "storage_account_kind" {
  type        = string
}

variable "storage_account_tier" {
  type        = string
}

variable "storage_account_type" {
  type        = string
}

variable "subnet_address_prefixes" {
  description = "subnet address prefixes"
  type        = list(any)
  default     = []
}

variable "mysqlserver_name" {
  type        = string
  description = "MySQL server Name"
}

variable "identity" {
  description = "If you want your SQL Server to have an managed identity. Defaults to false."
  default     = false
}

variable "mysqlserver_settings" {
  description = "MySQL server settings"
  type = object({
    administrator_login               = string
    administrator_password            = string
    zone                              = number
    mode                              = string
    sku_name                          = string
    version                           = string
    size_gb                           = number
    iops                              = number
    auto_grow_enabled                 = any
    backup_retention_days             = any
    geo_redundant_backup_enabled      = any
    database_name                     = string
    charset                           = string
    collation                         = string
    standby_availability_zone         = number
    maintenance_window_day_of_week    = number
    maintenance_window_start_hour     = number
    maintenance_window_start_minute   = number
  })
}

variable "create_mode" {
  description = "The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default`"
  default     = "Default"
}

variable "point_in_time_restore_time_in_utc" {
  description = "When `create_mode` is `PointInTimeRestore`, specifies the point in time to restore from `creation_source_server_id`"
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account name"
}

variable "enable_threat_detection_policy" {
  description = "Threat detection policy configuration, known in the API as Server Security Alerts Policy"
  default     = false
}

variable "email_addresses_for_alerts" {
  description = "A list of email addresses which alerts should be sent to."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "log_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
  default     = "30"
}

variable "mysql_configuration" {
  description = "Sets a MySQL Configuration value on a MySQL Server"
  type        = map(any)
  default     = {}
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure database for MySQL"
  default     = false
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Database Monitoring Category details for Azure Diagnostic setting"
  default     = ["MySqlSlowLogs", "MySqlAuditLogs"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  type        = string
}
variable "env" {
  type        = string
}
variable "team" {
  type        = string
}
variable "purpose" {
  type        = string
}