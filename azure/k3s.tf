# K3s Cluster Configuration for Azure

# Create resource group for K3s
resource "azurerm_resource_group" "k3s" {
  name     = "ameciclo-k3s-rg"
  location = var.azure_region
}

# Create virtual network
resource "azurerm_virtual_network" "k3s" {
  name                = "ameciclo-k3s-vnet"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.k3s.location
  resource_group_name = azurerm_resource_group.k3s.name
}

# Create subnet for K3s
resource "azurerm_subnet" "k3s" {
  name                 = "k3s-subnet"
  resource_group_name  = azurerm_resource_group.k3s.name
  virtual_network_name = azurerm_virtual_network.k3s.name
  address_prefixes     = ["10.20.1.0/24"]
}

# Create network security group
resource "azurerm_network_security_group" "k3s" {
  name                = "ameciclo-k3s-nsg"
  location            = azurerm_resource_group.k3s.location
  resource_group_name = azurerm_resource_group.k3s.name
}

# Allow SSH
resource "azurerm_network_security_rule" "k3s_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k3s.name
  network_security_group_name = azurerm_network_security_group.k3s.name
}

# Allow HTTP
resource "azurerm_network_security_rule" "k3s_http" {
  name                        = "AllowHTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k3s.name
  network_security_group_name = azurerm_network_security_group.k3s.name
}

# Allow HTTPS
resource "azurerm_network_security_rule" "k3s_https" {
  name                        = "AllowHTTPS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k3s.name
  network_security_group_name = azurerm_network_security_group.k3s.name
}

# Allow K3s API server
resource "azurerm_network_security_rule" "k3s_api" {
  name                        = "AllowK3sAPI"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k3s.name
  network_security_group_name = azurerm_network_security_group.k3s.name
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "k3s" {
  subnet_id                 = azurerm_subnet.k3s.id
  network_security_group_id = azurerm_network_security_group.k3s.id
}

# Create public IP
resource "azurerm_public_ip" "k3s" {
  name                = "ameciclo-k3s-pip"
  location            = azurerm_resource_group.k3s.location
  resource_group_name = azurerm_resource_group.k3s.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "k3s" {
  name                = "ameciclo-k3s-nic"
  location            = azurerm_resource_group.k3s.location
  resource_group_name = azurerm_resource_group.k3s.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.k3s.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.1.4"
    public_ip_address_id          = azurerm_public_ip.k3s.id
  }
}

# Create VM for K3s
resource "azurerm_linux_virtual_machine" "k3s" {
  name                = "ameciclo-k3s-vm"
  location            = azurerm_resource_group.k3s.location
  resource_group_name = azurerm_resource_group.k3s.name
  size                = "Standard_B2as_v2"

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  network_interface_ids = [
    azurerm_network_interface.k3s.id,
  ]

  tags = {
    Environment = "K3s"
    Project     = "Ameciclo"
  }
}

# Outputs
output "k3s_vm_public_ip" {
  value       = azurerm_public_ip.k3s.ip_address
  description = "Public IP of K3s VM"
}

output "k3s_vm_private_ip" {
  value       = azurerm_network_interface.k3s.private_ip_address
  description = "Private IP of K3s VM"
}

output "k3s_vm_ssh_command" {
  value       = "ssh azureuser@${azurerm_public_ip.k3s.ip_address}"
  description = "SSH command to connect to K3s VM"
}

