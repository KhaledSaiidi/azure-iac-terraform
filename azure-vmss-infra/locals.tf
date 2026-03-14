locals {
  name_prefix = "${var.resource_prefix}-${var.environment}"

  common_tags = merge(
    var.resource_tags,
    {
      environment = var.environment
      managed_by  = "terraform"
    }
  )

  nsg_rules = [
    {
      name                       = "allow-http-from-lb"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-https-from-lb"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                       = "deny-all-inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  lb_rules = [
    {
      name                    = "${local.name_prefix}-lb-http-rule"
      protocol                = "Tcp"
      frontend_port           = 80
      backend_port            = 80
      idle_timeout_in_minutes = 4
    }
  ]
}
