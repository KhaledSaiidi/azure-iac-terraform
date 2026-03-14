resource "random_pet" "lb_hostname" {
  length    = 4
  separator = "-"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "app" {
  name                 = "${local.name_prefix}-app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_app_prefixes
}

resource "azurerm_subnet" "mgmt" {
  name                 = "${local.name_prefix}-mgmt-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_mgmt_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.name_prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb_ip" {
  name                = "${local.name_prefix}-lb-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  domain_name_label   = "${local.name_prefix}-lb-${random_pet.lb_hostname.id}"
  tags                = local.common_tags
}

resource "azurerm_lb" "lb" {
  name                = "${local.name_prefix}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
  tags = local.common_tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "${local.name_prefix}-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${local.name_prefix}-lb-http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
  idle_timeout_in_minutes        = 4
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "${local.name_prefix}-lb-http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
  request_path        = "/"
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${local.name_prefix}-nat-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = local.common_tags
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${local.name_prefix}-nat-gateway"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = var.zones
  tags                    = local.common_tags
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_assoc" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.vm_public_ip.id
}
