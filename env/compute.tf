variable "dsc_config" {
  default = "CISHardenTest.ProdNode"
}


resource "azurerm_network_interface" "nic-cishardentest-main-server2016" {
    name                = "nic-cishardentest-main-server2016"
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg-cishardentest-main.id}"

    ip_configuration {
        name                          = "ipcfg-cishardentest-main"
        subnet_id                     = "${azurerm_subnet.snet-cishardentest-main.id}"
        private_ip_address_allocation = "Dynamic"
    }

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_network_security_group.nsg-cishardentest-main"]
}


resource "azurerm_virtual_machine" "vm-cishardentest-server2016-prd" {
    name                  = "server2016-prd"
    location              = "${var.g-location}"
    resource_group_name   = "${azurerm_resource_group.rg-main.name}"
    network_interface_ids = ["${azurerm_network_interface.nic-cishardentest-main-server2016.id}"]
    vm_size               = "${var.g-vmsize}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

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
        storage_uri = "${azurerm_storage_account.stor-cishardentest-main.primary_blob_endpoint}"
    }

    tags {
        environment = "cishardentest"
    }

    depends_on = ["azurerm_storage_account.stor-cishardentest-main"]
}

resource "azurerm_virtual_machine_extension" "dsc" {
  name                 = "Microsoft.Powershell.DSC"
  location             = "${var.g-location}"
  resource_group_name  = "${azurerm_resource_group.rg-main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm-cishardentest-server2016-prd.name}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"
  depends_on           = ["azurerm_virtual_machine.vm-cishardentest-server2016-prd"]

  settings = <<SETTINGS
        {
    "RegistrationUrl" : "${data.azurerm_key_vault_secret.sec-dsc-ep.value}",
    "NodeConfigurationName" : "${var.dsc_config}"
}
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    "configurationArguments": {
        "RegistrationKey": {
            "userName": "NOT_USED",
            "Password": "${data.azurerm_key_vault_secret.sec-dsc-pri-ak.value}"
        }
    }
}
PROTECTED_SETTINGS
}