terraform {
  backend "azurerm" {
    storage_account_name                  = "sadevcorestate"
    container_name                        = "terraform-state"
    key                                   = "cishardentest"
    resource_group_name                   = "rg-dev-core-tfstate"
  }
}

provider "azurerm" {
  version                                 = "1.19.0"
}