output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_name" {
  value = azurerm_public_ip.pip.name
}

output "storage_account" {
  value = azurerm_storage_account.sa.name
}