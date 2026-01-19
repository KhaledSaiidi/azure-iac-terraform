########################
# Resource Group
########################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = merge(var.tags, {
    env = var.environment
  })

  lifecycle {
    # PREVENT DESTROY:
    # This blocks `terraform destroy` and any plan that would delete the RG.
    # Useful as a safety belt for shared / critical RGs.
    prevent_destroy = true
  }
}


########################
# Public IP (replacement example)
########################
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.tags, {
    env = var.environment
  })

  lifecycle {
    # CREATE BEFORE DESTROY:
    # If a change forces replacement (e.g., name change via prefix),
    # Terraform will create the new Public IP first, then destroy the old one.
    # This reduces downtime in resources that attach to the Public IP.
    create_before_destroy = true

    # PRECONDITION:
    # Blocks apply early if constraints are not met.
    precondition {
      condition     = contains(["westeurope", "northeurope", "francecentral"], var.location)
      error_message = "location must be one of: westeurope, northeurope, francecentral."
    }
  }
}


########################
# Storage Account (ignore_changes example)
########################
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(var.tags, {
    env         = var.environment
    last_change = "managed-by-terraform"
  })

  lifecycle {
    # IGNORE CHANGES:
    # Azure/platform teams sometimes mutate tags automatically (policies, cost mgmt, etc.).
    # This tells Terraform: "do not try to revert tag drift for these keys/fields."
    #
    # Option A (simple): ignore ALL tags:
    # ignore_changes = [tags]
    #
    # Option B (more controlled): ignore just one tag key by ignoring the entire tags map
    # is not possible per-key; the typical practice is ignore tags entirely when needed.
    ignore_changes = [tags]

    # PRECONDITION:
    # Validates storage account naming rules at plan/apply time.
    precondition {
      condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
      error_message = "storage_account_name must be 3-24 characters."
    }
    precondition {
      condition     = can(regex("^[a-z0-9]+$", var.storage_account_name))
      error_message = "storage_account_name must contain only lowercase letters and numbers."
    }
  }
}

########################
# Storage Container (replace_triggered_by example)
########################
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id  = azurerm_storage_account.sa.id
  container_access_type = "private"

  lifecycle {
    # REPLACE TRIGGERED BY:
    # Forces this container to be replaced if the storage account resource changes
    # (for example: if the SA is recreated due to name change).
    # This makes the dependency and replacement behavior explicit and easy to reason about.
    replace_triggered_by = [
      azurerm_storage_account.sa
    ]
  }
}