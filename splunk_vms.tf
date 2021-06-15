# ====================================================================================
# Create SSH certs
# ====================================================================================

/* resource "tls_private_key" "splunk" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
output "tls_private_key" {
  value = tls_private_key.splunk.private_key_pem
  sensitive = true
} */

# ====================================================================================
# Primary Location
# ====================================================================================

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

  enable_automatic_updates           = true
  timezone                           = "AUS Eastern Standard Time"
  tags                               = var.common_tags
  depends_on                         = [azurerm_resource_group.rg, azurerm_network_interface.win]
}