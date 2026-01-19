output "rgname" {
  value = azurerm_resource_group.example[*].name # -. print the array of resource group names created
}

output "storage_name" {
  value = [for i in azurerm_storage_account.example : i.name] # -. print the array of storage account names created
}