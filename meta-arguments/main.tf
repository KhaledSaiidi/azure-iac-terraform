
resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-resources"
  location = var.allowed_locations[2]
}

# COUNT EXAMPLE:
resource "azurerm_storage_account" "example" {
  count = var.enable_storage_account ? length(var.storage_account_name) : 0
# conditional-->  condition ? value_if_true : value_if_false            
# && -> AND var.prod && var.enable_backup
# ! -> NOT !var.enable_public_access
  name                     = var.storage_account_name[count.index]
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

# FOREACH EXAMPLES:
resource "azurerm_storage_account" "sa" {
  name                     = "st${var.environment}001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# 1. FOREACH on list EXAMPLES:
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.container_names)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# 2. FOREACH on MAP EXAMPLES:
resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups

  name     = "${var.environment}-${each.key}-rg"
  location = each.value
}

# 3. FOREACH on Object EXAMPLES:
resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts

  name                     = "st${var.environment}${each.key}001" 
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = each.value.replication_type

  tags = each.value.tags
}
