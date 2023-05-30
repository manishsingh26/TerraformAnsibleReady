
# Create Security Group to access linux
resource "azurerm_network_security_group" "linux-vm-nsg" {
  depends_on=[azurerm_resource_group.smart-network-rg]
  name = "linux-vm-nsg"
  location            = azurerm_resource_group.smart-network-rg.location
  resource_group_name = azurerm_resource_group.smart-network-rg.name

  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Associate the linux NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "linux-vm-nsg-association" {
  depends_on=[azurerm_resource_group.smart-network-rg]
  subnet_id                 = azurerm_subnet.smart-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.linux-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "linux-vm-ip" {
  depends_on=[azurerm_resource_group.smart-network-rg]
  count = var.vm_count
  name                = "linux-vm-ip-${count.index}"
  location            = azurerm_resource_group.smart-network-rg.location
  resource_group_name = azurerm_resource_group.smart-network-rg.name
  allocation_method   = "Static"
}

# Create Network Card for linux VM
resource "azurerm_network_interface" "linux-vm-nic" {
  depends_on=[azurerm_resource_group.smart-network-rg]
  count = var.vm_count
  name                = "linux-vm-nic-${count.index}"
  location            = azurerm_resource_group.smart-network-rg.location
  resource_group_name = azurerm_resource_group.smart-network-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.smart-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.linux-vm-ip.*.id, count.index)
  }
}

# Create Linux VM with linux server
resource "azurerm_linux_virtual_machine" "linux-vm" {
  depends_on=[azurerm_network_interface.linux-vm-nic]
  count = var.vm_count
  location              = azurerm_resource_group.smart-network-rg.location
  resource_group_name   = azurerm_resource_group.smart-network-rg.name
  name                  = var.vm-details[count.index].vm_name
  network_interface_ids = [element(azurerm_network_interface.linux-vm-nic.*.id, count.index),]
  size                  = var.linux_vm_image_publisher

  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "linux-vm-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = var.vm-details[count.index].vm_name
  admin_username = var.vm-details[count.index].vm_username
  admin_password = var.vm-details[count.index].vm_password
  # custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  disable_password_authentication = false

}

# #Template for bootstrapping
# data "template_file" "linux-vm-cloud-init" {
#   template = file("azure-user-data.sh")
# }

# resource "local_file" "smart-vm-ip" {
#     content  = azurerm_public_ip.linux-vm-ip.ip_address
#     filename = "vm-ip.txt"
# }

# output "vm-ip" {
#   value = azurerm_public_ip.linux-vm-ip.*.ip_address
# }

# output "vm-name" {
#   value = azurerm_linux_virtual_machine.linux-vm.*.name
# }

output "vm-info" {
  value = [azurerm_linux_virtual_machine.linux-vm.*.name, azurerm_public_ip.linux-vm-ip.*.ip_address]
}