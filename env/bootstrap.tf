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

resource "azurerm_virtual_network" "net-cishardentest-main" {
    name                = "net-cishardentest-main"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_resource_group.rg-main"]
}

resource "azurerm_subnet" "snet-cishardentest-main" {
    name                 = "snet-cishardentest-main"
    resource_group_name  = "${azurerm_resource_group.rg-main.name}"
    virtual_network_name = "${azurerm_virtual_network.net-cishardentest-main.name}"
    address_prefix       = "10.0.2.0/24"

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_virtual_network.net-cishardentest-main"]
}

resource "azurerm_public_ip" "pubip-cishardentest-main" {
    name                         = "pubip-cishardentest-main"
    location                     = "${var.g-location}"
    resource_group_name          = "${azurerm_resource_group.rg-main.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "cishardentest"
    }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "${var.locale}"
    resource_group_name   = "${azurerm_resource_group.rg-main.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "${var.vmsize}"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${var.sshkeydata}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "TerraformTest"
    }
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    location            = "${var.locale}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "TerraformTest"
    }

    depends_on = ["azurerm_resource_group.rg-main"]
}
