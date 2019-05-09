resource "azurerm_virtual_network" "net-cishardentest-main" {
    name                = "net-cishardentest-main"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"

    tags {
        environment = "cishardentest"
    }
}

resource "azurerm_subnet" "snet-cishardentest-main" {
    name                 = "snet-cishardentest-main"
    resource_group_name  = "${azurerm_resource_group.rg-main.name}"
    virtual_network_name = "${azurerm_virtual_network.net-cishardentest-main.name}"
    address_prefix       = "10.0.2.0/24"

    tags {
        environment = "cishardentest"
    }
}

resource "azurerm_public_ip" "pubip-cishardentest-main" {
    name                         = "pubip-cishardentest-main"
    location                     = "${var.g-location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "cishardentest"
    }
}