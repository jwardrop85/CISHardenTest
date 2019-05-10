#variable g-location {}
#variable g-core-kv {}
#variable g-core-rg {}


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
    public_ip_address_id = "${azurerm_public_ip.pubip-cishardentest-main-lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lbbend-cishardentest-main-server" {
  resource_group_name = "${azurerm_resource_group.rg-main.name}"
  loadbalancer_id     = "${azurerm_lb.lb-cishardentest-main.id}"
  name                = "lbbend-cishardentest-main-server"
}

resource "azurerm_lb_nat_rule" "nat-RDPAccess" {
  resource_group_name            = "${azurerm_resource_group.rg-main}"
  loadbalancer_id                = "${azurerm_lb.lb-cishardentest-main.id}"
  name                           = "nat-RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 54523
  backend_port                   = 3389
  frontend_ip_configuration_name = "${azurerm_public_ip.pubip-cishardentest-main-lb.name}"
}