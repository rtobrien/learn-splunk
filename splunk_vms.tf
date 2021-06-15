# ====================================================================================
# Create SSH certs
# ====================================================================================

resource "tls_private_key" "splunk" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
output "tls_private_key" {
  value = tls_private_key.splunk.private_key_pem
  sensitive = true
}

# ====================================================================================
# Primary Location
# ====================================================================================

resource "azurerm_linux_virtual_machine" "lvm" {
  count                                 = var.instance_count
  name                                  = "lvm-0${count.index + 1}"
  admin_username                        = var.username
  admin_password                        = var.password
  location                              = var.location
  resource_group_name                   = var.rg_name
  network_interface_ids                 = [element(azurerm_network_interface.lnx.*.id, count.index)]
  size                                  = "Standard_B2s"
  disable_password_authentication       = true

  admin_ssh_key {
    username                            = var.username
    public_key                          = tls_private_key.splunk.public_key_openssh
  }

  source_image_reference {
    publisher                           = "RedHat"
    offer                               = "RHEL"
    sku                                 = "8.2"
    version                             = "latest"
  }

  os_disk {
    name                                = "lvm-0${count.index + 1}-os-disk" 
    caching                             = "ReadWrite"
    storage_account_type                = "Standard_LRS"
  }

  tags                                  = var.common_tags
  depends_on                            = [azurerm_resource_group.rg, azurerm_network_interface.lnx, tls_private_key.splunk]
}

resource "azurerm_windows_virtual_machine" "win" {
  count                                 = var.win_instance_count
  computer_name                         = "win-0${count.index + 1}"
  name                                  = "win-0${count.index + 1}"
  admin_username                        = var.username
  admin_password                        = var.password
  location                              = var.location
  resource_group_name                   = var.rg_name
  size                                  = "Standard_D2s_v3"
  network_interface_ids                 = [element(azurerm_network_interface.win.*.id, count.index)]
  os_disk {
        name                            = "win-0${count.index + 1}"                # Optional: The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created.
        storage_account_type            = "Standard_LRS"
        caching                         = "ReadWrite"
    }
    source_image_reference {
        publisher                       = "MicrosoftWindowsServer"
        offer                           = "WindowsServer"
        sku                             = "2019-Datacenter"
        version                         = "latest"
    }

  enable_automatic_updates           = false
  timezone                           = "AUS Eastern Standard Time"
  tags                               = var.common_tags
  depends_on                         = [azurerm_resource_group.rg, azurerm_network_interface.win]
}

/* resource "azurerm_virtual_machine_extension" "splunk" {
  name                                  = "splunk-extn"
  depends_on                            = [azurerm_linux_virtual_machine.splunk]
  count                                 = var.instance_count
  virtual_machine_id                    = azurerm_linux_virtual_machine.splunk[count.index].id
  publisher                             = "Microsoft.Azure.Extensions"
  type                                  = "CustomScript"
  type_handler_version                  = "2.0"

# TODO - REPLACE WITH LOCAL OR PERSONAL STORAGE BUCKET
      settings = <<SETTINGS
    {
        "fileUris":["https://rtobtfstate.blob.core.windows.net/tfstate/splunk_installer.sh"]
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "bash splunk_installer.sh" 
    }
PROTECTED_SETTINGS
} */