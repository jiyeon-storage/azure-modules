output "azurerm_mysql_flexible_server_name" {
  value = azurerm_mysql_flexible_server.main.name
}

output "azurerm_mysql_flexible_database_name" {
  value = azurerm_mysql_flexible_database.this.name
}