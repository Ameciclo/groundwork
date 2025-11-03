# Virtual Network
resource "azurerm_virtual_network" "ameciclo" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
}

# K3s Subnet
resource "azurerm_subnet" "k3s" {
  name                 = "k3s-subnet"
  resource_group_name  = azurerm_resource_group.ameciclo.name
  virtual_network_name = azurerm_virtual_network.ameciclo.name
  address_prefixes     = ["10.10.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Database Subnet
resource "azurerm_subnet" "database" {
  name                 = var.database_subnet_name
  resource_group_name  = azurerm_resource_group.ameciclo.name
  virtual_network_name = azurerm_virtual_network.ameciclo.name
  address_prefixes     = var.database_subnet_prefix

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Network Security Group for K3s
resource "azurerm_network_security_group" "k3s" {
  name                = "${var.project_name}-k3s-nsg"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
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
  resource_group_name         = azurerm_resource_group.ameciclo.name
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
  resource_group_name         = azurerm_resource_group.ameciclo.name
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
  resource_group_name         = azurerm_resource_group.ameciclo.name
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
  resource_group_name         = azurerm_resource_group.ameciclo.name
  network_security_group_name = azurerm_network_security_group.k3s.name
}



# Network Security Group for Database
resource "azurerm_network_security_group" "database" {
  name                = "${var.project_name}-database-nsg"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
}



# Allow PostgreSQL from K3s subnet
resource "azurerm_network_security_rule" "allow_postgres_k3s" {
  name                        = "AllowPostgresK3s"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.10.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ameciclo.name
  network_security_group_name = azurerm_network_security_group.database.name
}

# Associate NSG with K3s subnet
resource "azurerm_subnet_network_security_group_association" "k3s" {
  subnet_id                 = azurerm_subnet.k3s.id
  network_security_group_id = azurerm_network_security_group.k3s.id
}

# Associate NSG with Database subnet
resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.database.id
}

# Create public IP for K3s VM
resource "azurerm_public_ip" "k3s" {
  name                = "ameciclo-k3s-pip"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Create network interface for K3s VM
resource "azurerm_network_interface" "k3s" {
  name                = "ameciclo-k3s-nic"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.k3s.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.4"
    public_ip_address_id          = azurerm_public_ip.k3s.id
  }

  tags = var.tags
}

# Create K3s VM
resource "azurerm_linux_virtual_machine" "k3s" {
  name                = "ameciclo-k3s-vm"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name
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

  tags = merge(
    var.tags,
    {
      Name = "K3s"
    }
  )
}

