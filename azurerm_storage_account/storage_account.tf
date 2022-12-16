# account_tier : Standard, Premium
# account_replication_type : LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS

resource "azurerm_storage_account" "this" {
  #for_each = var.sa_config == null ? {} : var.sa_config
  for_each = { for k,v in var.sa_config : k => v if k != null }

  name                     = lookup(each.value, "sa_name", null)
  resource_group_name      = lookup(each.value, "resource_group_name", null)
  location                 = var.location
  account_tier             = lookup(each.value, "sa_tier", "Standard")
  account_replication_type = lookup(each.value, "sa_type", "LRS")
  blob_properties{
    cors_rule{
        #allowed_headers = ["*"]
        #allowed_methods = ["GET","HEAD","POST"]
        #allowed_origins = ["*"]
        #exposed_headers = ["*"]
        max_age_in_seconds = 300

        allowed_headers = lookup(each.value, "blob_cors_headers", ["*"])
        allowed_methods = lookup(each.value, "blob_cors_methods", ["GET","HEAD","POST","PUT"])
        allowed_origins = lookup(each.value, "blob_cors_origins", ["*"])
        exposed_headers = lookup(each.value, "blob_cors_expose_headers", ["*"])
        }
  }

  share_properties{
    cors_rule{
        #allowed_headers = ["*"]
        #allowed_methods = ["GET","HEAD","POST"]
        #allowed_origins = ["*"]
        #exposed_headers = ["*"]
        max_age_in_seconds = 300

        allowed_headers = lookup(each.value, "file_cors_headers", ["*"])
        allowed_methods = lookup(each.value, "file_cors_methods", ["GET","HEAD","POST","PUT"])
        allowed_origins = lookup(each.value, "file_cors_origins", ["*"])
        exposed_headers = lookup(each.value, "file_cors_expose_headers", ["*"])
        }
  }

  queue_properties{
    cors_rule{
        #allowed_headers = ["*"]
        #allowed_methods = ["GET","HEAD","POST"]
        #allowed_origins = ["*"]
        #exposed_headers = ["*"]
        max_age_in_seconds = 300

        allowed_headers = lookup(each.value, "queue_cors_headers", ["*"])
        allowed_methods = lookup(each.value, "queue_cors_methods", ["GET","HEAD","POST","PUT"])
        allowed_origins = lookup(each.value, "queue_cors_origins", ["*"])
        exposed_headers = lookup(each.value, "queue_cors_expose_headers", ["*"])
        }
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }

    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }

    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  tags = merge(local.default_tags, {
    sa_name = format("%s%s-%s-%s-sa", var.prefix, var.env, var.purpose, var.resource_group_name)
  })
}
