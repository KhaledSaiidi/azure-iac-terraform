locals {
  formatted_name = lower(replace(var.project_name, " ", "-"))
  
  merged_tags = merge(
    var.default_tags,
    var.environment_tags
  )

  storage_formatted = substr( join("", regexall("[a-z0-9]", lower(var.storage_account_name))), 0, 23)
  # 👉 we can't use trim() because it only removes characters from the START and END of the string, not the middle.
  # regexall() → finds all parts of a string that match a regex and returns them as a list of strings.
  # join() → combines a list of strings into one string, using a given separator.


  formatted_ports = [for p in split(",", var.allowed_ports) : trimspace(p)]

  nsg_rules = [ for i, port in local.formatted_ports : {
    name = "port-${port}"
    port = port
    priority    = 100 + i
    description = "Allow traffic on port ${port}"
  }]



  # lookup for vm size based on environment
  vm_size = lookup(var.vm_sizes, var.environment, "Standard_B2s")
}
resource "azurerm_resource_group" "rg" {
    name     = "${local.formatted_name}-rg"
    location = "West Europe"
    tags = local.merged_tags
}

resource "azurerm_storage_account" "storage_account" {
  name                     = local.storage_formatted
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.merged_tags
}

resource "azurerm_network_security_group" "network_security_group" {
  name     = "${local.formatted_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
        name                       = security_rule.value.name
        priority                   = security_rule.value.priority
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = security_rule.value.port
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = security_rule.value.description
    }
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = "${var.environment}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = local.vm_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}