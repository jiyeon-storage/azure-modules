variable "resource_group_name" {
  type        = string
  description = "The name of resource group"
}

variable "location" {
  type        = string
  description = "Azure location "
}

variable "redis_cluster_config" {
  type        = any
  description = "Redis Cluster Config"
}

variable "redis_instance_config" {
  type        = any
  description = "Redis instance Config"
}

variable "enable_private_endpoint" {
  type        = bool
  description = ""
  default     = true
}

variable "existing_private_dns_zone" {
  type        = string
  description = ""
  default     = null
}

variable "vnet_id" {
  type        = string
  description = "Required DB Vnet ID"
}

variable "zones" {
  type        = any
  description = "zones"
}

variable "subnet_id" {
  type        = string
  description = "Required DB Subnet ID"
}

variable "storage_account_id" {
  type        = string
  description = "storage account id"
  default     = null
}

variable "storage_account_primary_blob_connection_string" {
  type        = string
  description = "blob connection url"
  default     = null
}

variable "workspace_id" {
  type        = string
  description = "workspace id"
  default     = null
}

variable "firewall_rules" {
  type        = any
  description = "FireWall Rules Config"
  default     = {}
}

variable "storage_account_name" {
  type        = string
  description = "Backup And Logs saved to Storage Account"
  default     = null
}

variable "enable_data_persistence" {
  description = "Enable or disbale Redis Database Backup. Only supported on Premium SKU's"
  default     = false
}

variable "data_persistence_backup_frequency" {
  description = "The Backup Frequency in Minutes. Only supported on Premium SKU's. Possible values are: `15`, `30`, `60`, `360`, `720` and `1440`"
  default     = 60
}

variable "data_persistence_backup_max_snapshot_count" {
  description = "The maximum number of snapshots to create as a backup. Only supported for Premium SKU's"
  default     = 1
}


variable "redis_family" {
  type        = map(any)
  description = "The SKU family/pricing group to use. Valid values are `C` (for `Basic/Standard` SKU family) and `P` (for `Premium`)"
  default = {
    Basic    = "C"
    Standard = "C"
    Premium  = "P"
  }
}

variable "patch_schedule" {
  type = object({
    day_of_week    = string
    start_hour_utc = number
  })
  description = "The window for redis maintenance. The Patch Window lasts for 5 hours from the `start_hour_utc` "
  default     = null
}


variable "log_sku" {
  type    = string
  default = "Free"
}
variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "team" {
  type = string
}

variable "purpose" {
  type = string
}
