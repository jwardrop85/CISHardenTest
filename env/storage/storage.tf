variable g-location {}
variable g-vmsize {}
variable g-sshkeydata {}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "${var.locale}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "TerraformTest"
    }
}
