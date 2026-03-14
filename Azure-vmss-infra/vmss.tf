data "azurerm_platform_image" "image" {
  location  = azurerm_resource_group.rg.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_infra" {
  name                        = "${var.environment}-vmss-infra"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.name
  sku_name                    = "Standard_DS1_v2"
  instances                   = 3
  platform_fault_domain_count = 1
  zones                       = ["1"]
  user_data_base64            = base64encode(file("user-data.sh"))

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = "azureuser"
      admin_ssh_key {
        username   = "azureuser"
        public_key = file("~/.ssh/id_rsa.pub")
      }
    }
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.image.publisher
    offer     = data.azurerm_platform_image.image.offer
    sku       = data.azurerm_platform_image.image.sku
    version   = data.azurerm_platform_image.image.version
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "${var.environment}-vmss-infra-nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name                                   = "${var.environment}-vmss-infra-ipconfig"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}
