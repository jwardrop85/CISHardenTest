variable g-location {}
variable g-vmsize {}
variable g-sshkeydata {}
variable g-core-kv {}
variable g-core-rg {}

data "azurerm_key_vault" "kv-dev-core" {
  name                = "${var.g-core-kv}"
  resource_group_name = "${var.g-core-rg}"
}

output "vault_uri" {
  value = "${data.azurerm_key_vault.kv-dev-core.vault_uri}"
}
data "azurerm_key_vault_secret" "adm-usr-server2016-prd" {
  name      = "adm-usr-server2016-prd"
  key_vault_id = "${data.azurerm_key_vault.kv-dev-core.adm-usr-server2016-prd}"
}

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

resource "azurerm_network_interface" "nic-cishardentest-main-server2016" {
    name                = "nic-cishardentest-main-server2016"
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.snet-cishardentest-main.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.pubip-cishardentest-main.id}"
    }

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_subnet.snet-cishardentest-main"]
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rg-main.name}"
    }
    
    byte_length = 8

}


resource "azurerm_virtual_machine" "vm-cishardentest-server2016-prd" {
    name                  = "server2016-prd"
    location              = "${var.g-location}"
    resource_group_name   = "${azurerm_resource_group.rg-main.name}"
    network_interface_ids = ["${azurerm_network_interface.nic-cishardentest-main-server2016.id}"]
    vm_size               = "${var.g-vmsize}"

    storage_os_disk {
        name              = "disk-cishardentest-server2016-prd"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference  {
        publisher="MicrosoftWindowsServer"
        offer="WindowsServer"
        sku="2016-Datacenter"
        version="latest"
    }

    os_profile {
        computer_name  = "server2016-prd"
        admin_username = "azureadmin"
        admin_password = "${data.azurerm_key_vault_secret.adm-usr-server2016-prd.value}"
    }

    os_profile_windows_config {
        timezone = "GMT Standard Time"
        provision_vm_agent = "true"
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "cishardentest"
    }
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    location            = "${var.locale}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_resource_group.rg-main"]
}
