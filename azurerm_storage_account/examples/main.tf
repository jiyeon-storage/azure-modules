module "storage" {
  source = "../"
  location = local.location
  resource_group_name = "jay-test-rg"

  sa_config = [
    { 
      sa_tier = "Standard"
      sa_type = "LRS"
      sa_name = "test123123123"
      resource_group_name = "jay-test-rg"
      blob_cors_methods = ["GET","HEAD","POST"]
    }
  ]

  sc_config = [
    {
      sc_name = "test123sc"
      sa_name = "test123123123"
      ca_type = "private"
    },
    {
      sc_name = "test123123sc"
      sa_name = "test123123123"
      ca_type = "container"
    }
  ]

  #sb_config = [
  #  {
  #    sb_name = "testsasb123"
  #    sc_name = "testsasa12sc"
  #    sa_name = "test123123123"
  #    sb_type = "Block"  # Default Block. not require
  #  }
  #]

  ss_config = [
    {
      ss_name = "test1234ss"
      sa_name = "test123123123"
      quota   = 50
    }
  ]

  #depends_on = module.storage

  # default tag
  prefix  = local.prefix
  env     = local.env
  purpose = local.purpose
  team    = local.team
}
