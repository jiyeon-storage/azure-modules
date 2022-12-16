# container_access_type : (Optional) blob, container, private.  Default private. 

resource "azurerm_storage_container" "this" {
  for_each = { for k,v in var.sc_config : k => v if k != null }

  name                     = lookup(each.value, "sc_name", null)
  storage_account_name     = lookup(each.value, "sa_name", null)
  container_access_type    = lookup(each.value, "ca_type", "private")
  
  depends_on = [azurerm_storage_account.this]
}
