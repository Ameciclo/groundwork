# Virtual Network
resource "azurerm_virtual_network" "ameciclo" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
}

# VM Subnet
resource "azurerm_subnet" "vm" {
  name                 = var.vm_subnet_name
  resource_group_name  = azurerm_resource_group.ameciclo.name
  virtual_network_name = azurerm_virtual_network.ameciclo.name
  address_prefixes     = var.vm_subnet_prefix
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

# Network Security Group for VM
resource "azurerm_network_security_group" "vm" {
  name                = "${var.project_name}-vm-nsg"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
}

# Allow SSH
resource "azurerm_network_security_rule" "allow_ssh" {
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
  network_security_group_name = azurerm_network_security_group.vm.name
}

# Allow HTTP
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ameciclo.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

# Allow HTTPS
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ameciclo.name
  network_security_group_name = azurerm_network_security_group.vm.name
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
  source_address_prefix       = var.k3s_subnet_prefix[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ameciclo.name
  network_security_group_name = azurerm_network_security_group.database.name
}

# Associate NSG with VM subnet
resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Associate NSG with Database subnet
resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.database.id
}

# VNet Peering: Connect main VNet to K3s VNet
resource "azurerm_virtual_network_peering" "main_to_k3s" {
  name                      = "main-to-k3s"
  resource_group_name       = azurerm_resource_group.ameciclo.name
  virtual_network_name      = azurerm_virtual_network.ameciclo.name
  remote_virtual_network_id = azurerm_virtual_network.k3s.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering: Connect K3s VNet to main VNet
resource "azurerm_virtual_network_peering" "k3s_to_main" {
  name                      = "k3s-to-main"
  resource_group_name       = azurerm_resource_group.k3s.name
  virtual_network_name      = azurerm_virtual_network.k3s.name
  remote_virtual_network_id = azurerm_virtual_network.ameciclo.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

