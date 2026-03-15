terraform {
  backend "azurerm" {
    resource_group_name  = "rg-platform-tfstate"
    storage_account_name = "platengtfstate1773573416"
    container_name       = "tfstate001"
    key                  = "ks.terraform.tfstate"
  }
}
