output "redis" {
    value = { for k, v in azurerm_redis_cache.this :
        k => {
          id = v.id
          name = v.name
     }   
    }
}