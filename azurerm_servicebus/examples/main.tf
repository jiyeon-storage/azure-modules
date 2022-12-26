resource "azurerm_resource_group" "this" {
  name = "jay-test-rg"
  location = local.location
}

module "service_bus" {
  source = "../" 
  prefix    = local.prefix
  env       = local.env
  team      = local.team
  purpose   = local.purpose
  location  = local.location
  name = format("%s%s-%s-sbbbs",local.prefix, local.env, local.purpose)

  resource_group_name = azurerm_resource_group.this.name

  topics = [
    {
      name = "source"
      enable_partitioning = true
      subscriptions = [
        {
          name = "example"
          forward_to = "destination"
          max_delivery_count = 1
        }
      ]
    },
    {
      name = "destination"
      enable_partitioning = true
    }
  ]

  # queues = [
  #   {
  #     name = "example"
  #     authorization_rules = [
  #       {
  #         name   = "example"
  #         rights = ["listen", "send"]
  #       }
  #     ]
  #   }
  # ]
}
