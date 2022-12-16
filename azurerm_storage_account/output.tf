output "sa_name" {
    value = { for k, v in azurerm_storage_account.this :
        k => {
          name = v.name
     }
    }
}

output "sa_id" {
    value = { for k, v in azurerm_storage_account.this :
        k => {
          id = v.id
     }
    }
}

