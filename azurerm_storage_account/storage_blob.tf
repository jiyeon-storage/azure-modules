# type : Block, Append, Page

resource "azurerm_storage_blob" "this" {
  for_each = { for k,v in var.sb_config : k => v if k != null }

  name                   = lookup(each.value, "sb_name", null)
  storage_account_name   = lookup(each.value, "sa_name", null)
  storage_container_name = lookup(each.value, "sc_name", null)
  type                   = lookup(each.value, "sb_type", null)

  depends_on = [azurerm_storage_container.this]
}
