locals {
  default_tags = {
    env        = var.env
    team       = var.team
    purpose    = var.purpose
    prefix  = var.prefix
  }

  #  azurerm_subnets = {
  #  for subnet in azurerm_subnet.subnet :
  #  subnet.name => subnet.id
  #}
}
