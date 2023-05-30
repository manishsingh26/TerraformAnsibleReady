
# Create a resource group for network
resource "azurerm_resource_group" "smart-network-rg" {
  name = var.rg_name
  location = var.rg_location
}

# Create the network VNET
resource "azurerm_virtual_network" "smart-network-vnet" {
  name = "network-vnet"
  address_space = [var.network-vnet-cidr]
  resource_group_name = azurerm_resource_group.smart-network-rg.name
  location = azurerm_resource_group.smart-network-rg.location
}

# Create a subnet for VM
resource "azurerm_subnet" "smart-vm-subnet" {
  name = "vm-subnet"
  address_prefixes = [var.network-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.smart-network-vnet.name
  resource_group_name  = azurerm_resource_group.smart-network-rg.name
}
