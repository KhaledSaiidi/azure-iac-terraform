terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-azure-lab"
    storage_account_name = "ks072"
    container_name       = "tfstate"
    key                  = "ks.terraform.tfstate"
  }
}