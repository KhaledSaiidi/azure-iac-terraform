resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_network_security_group" "example" {
  ##                  condition ? true_val : false_val
  name                = var.environment == "uat" ? "nsg-${var.environment}" : "nsg-prod"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

# Dynamically generates multiple `security_rule` blocks inside the parent resource
  dynamic "security_rule" {
    # Iterates over each rule definition in local.nsg_rules
    for_each = local.nsg_rules
    # Defines the content of each generated security_rule block
    content {
      # Uses the current rule's name from the iteration
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description = security_rule.value.description
    }
  }

  tags = {
    environment = "Production"
  }
}