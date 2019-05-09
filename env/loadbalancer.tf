variable g-location {}
variable g-core-kv {}
variable g-core-rg {}


resource "azurerm_public_ip" "pubip-cishardentest-main-lb" {
    name                         = "pubip-cishardentest-main"
    location                     = "${var.g-location}"
    resource_group_name          = "${azurerm_resource_group.rg-main.name}"
    allocation_method            = "Static"

    tags {
        environment = "cishardentest"
    }
}
resource "azurerm_lb" "lb-cishardentest-main" {
  name                = "lb-cishardentest-main"
  location            = "${var.g-location}"
  resource_group_name = "${azurerm_resource_group.rg-main.name}"

  frontend_ip_configuration {
    name                 = "lb-cishardentest-main-fendip"
    public_ip_address_id = "${azurerm_public_ip.pubip-cishardentest-main-lb.public_ip_address_id}"
  }
}