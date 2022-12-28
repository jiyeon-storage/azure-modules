resource "azurerm_resource_group" "this" {
  name     = format("%s%s-%s", var.prefix, var.env, var.purpose)
  location = var.location
  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}

resource "azurerm_management_lock" "this" {
  count      = var.lock ? 1 : 0
  name       = format("%s%s-%s", var.prefix, var.env, var.purpose)
  scope      = azurerm_resource_group.this.id
  lock_level = var.lock_level
  notes      = var.lock_descriptions
}
