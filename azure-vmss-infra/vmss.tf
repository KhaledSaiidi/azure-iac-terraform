data "azurerm_platform_image" "image" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_infra" {
  name                        = "${local.name_prefix}-vmss-infra"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = var.location
  sku_name                    = lookup(var.vmss_sku_by_env, var.environment, var.vmss_sku_default)
  instances                   = var.default_capacity
  platform_fault_domain_count = 1
  user_data_base64            = base64encode(file("${path.module}/user-data.sh"))

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = var.admin_username
      admin_ssh_key {
        username   = var.admin_username
        public_key = var.ssh_public_key
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
    disk_size_gb         = var.os_disk_size_gb
  }

  network_interface {
    name                          = "${local.name_prefix}-vmss-infra-nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name                                   = "${local.name_prefix}-vmss-infra-ipconfig"
      subnet_id                              = azurerm_subnet.app.id
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
