resource "azurerm_resource_group" "this" {
  name     = "jay-test-rg"
  location = local.location
}

module "vnet" {
  source = "../"

  # default tag
  prefix  = local.prefix
  env     = local.env
  purpose = local.purpose
  team    = local.team

  # rg bind
  resource_group_name = "jay-test-rg"
  # vnet 
  cidrs    = ["10.111.0.0/16"]
  location = local.location

  # subnet
  subnet_cidrs = {
    public  = ["10.111.0.0/24"]
    private = ["10.111.1.0/24"]
    db      = ["10.111.2.0/24"]
  }

  # not used 
  subnet_tags = {
    public = {
      "kubernetes.io/role/elb" = "1"
      "immutable_metadata"     = jsonencode({ purpose = "jay-public-subnet" })
    }
    private = {
      "immutable_metadata" = jsonencode({ purpose = "jay-private-subnet" })
    }
  }
}
