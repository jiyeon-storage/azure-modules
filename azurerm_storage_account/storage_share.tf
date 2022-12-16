resource "azurerm_storage_share" "this" {
  for_each = { for k,v in var.ss_config : k => v if k != null }

  name                 = lookup(each.value, "ss_name", null)
  storage_account_name = lookup(each.value, "sa_name", null)
  quota                = lookup(each.value, "quota", null)

  #acl {
    #id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"
    #access_policy {
    #  permissions = "rwdl"
    #  start       = "2019-07-02T09:38:21.0000000Z"
    #  expiry      = "2019-07-02T10:38:21.0000000Z"
    #}
  #}

  depends_on = [azurerm_storage_account.this]
}
