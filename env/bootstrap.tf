variable g-location {}
variable g-vmsize {}
variable g-sshkeydata {}
provider "azurerm" {
}

resource "azurerm_resource_group" "rg-main" {
        name = "rg-cishardentest-main"
        location = "${var.g-location}"

        tags {
            environment = "cishardentest"
        }
}

module "network" {
  source = "./network"
  
}

module "compute" {
  source = "./compute"

}