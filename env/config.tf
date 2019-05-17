terraform {
  backend "azurerm" {
    storage_account_name                  = "sadevcorestate"
    container_name                        = "terraform-state"
    key                                   = "cishardentest"
    resource_group_name                   = "rg-dev-core-tfstate"
  }
}


variable "subs_id"{
  
}
variable "client_id"{
  
}
variable "client_secret"{
  
}
variable "tenant_id"{
  
}

provider "azurerm" {
  version                                 = "1.27.1"
  subscription_id = "${var.subs_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}