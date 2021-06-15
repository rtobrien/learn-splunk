# ====================================================================================
# Create VNETs (and subnets)
# ====================================================================================

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_address_space
  tags = merge(var.common_tags, {"Resource Type" = "vnet"})

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  count = var.instance_count
  name           = "subnet${count.index + 1}"
  address_prefixes = ["10.0.${count.index}.0/24"]
  virtual_network_name = var.vnet_name
  resource_group_name = var.rg_name
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# resource "azurerm_subnet" "subnet02" {
#   name           = "subnet2"
#   address_prefixes = ["10.0.1.0/24"]
#   virtual_network_name = var.vnet_name
#   resource_group_name = var.rg_name
#   depends_on = [
#     azurerm_virtual_network.vnet
#   ]
#   }

# ====================================================================================
# Create NSGs and Associations
# ====================================================================================

resource "azurerm_network_security_group" "nsg" {
  name                = "splunk-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "rdp-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  count = var.instance_count
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg]
}

# ====================================================================================
# Create PIPs
# ====================================================================================

resource "azurerm_public_ip" "lnx" {
  count               = var.instance_count
  name                = "linux-pip-0${count.index}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
  tags = var.common_tags
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "win" {
  count               = var.instance_count
  name                = "win-pip-0${count.index}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
  tags = var.common_tags
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vnet]
}

# ====================================================================================
# Create NICs
# ====================================================================================

resource "azurerm_network_interface" "lnx" {
  count                          = var.instance_count
  name                           = "lnx-0${count.index + 1}-nic"
  location                       = var.location
  resource_group_name            = var.rg_name

  ip_configuration {
    name                         = "lnx-ipconfig-0${count.index + 1}"
    subnet_id                    = azurerm_subnet.subnet[count.index % 2].id
    private_ip_address_allocation= "static"
    private_ip_address           = "10.0.${count.index % 2}.${69 + count.index}"
    public_ip_address_id         = azurerm_public_ip.lnx[count.index].id
  }
}

resource "azurerm_network_interface" "win" {
  count                          = var.win_instance_count
  name                           = "win-0${count.index + 1}-nic"
  location                       = var.location
  resource_group_name            = var.rg_name

  ip_configuration {
    name                         = "win-ipconfig-0${count.index + 1}"
    subnet_id                    = azurerm_subnet.subnet[count.index % 2].id
    private_ip_address_allocation= "static"
    private_ip_address           = "10.0.${count.index % 2}.${69 + var.instance_count + count.index}"
    public_ip_address_id         = azurerm_public_ip.win[count.index].id
  }
}

# ====================================================================================
# Outputs
# ====================================================================================

output "pips-lnx" {
  value = azurerm_public_ip.lnx
}

output "pips-win" {
  value = azurerm_public_ip.win
}