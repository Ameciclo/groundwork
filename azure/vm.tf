# Public IP for VM
resource "azurerm_public_ip" "vm" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Network Interface for VM
resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = var.tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = azurerm_resource_group.ameciclo.location
  resource_group_name = azurerm_resource_group.ameciclo.name
  size                = var.vm_size

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.vm_os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  tags = var.tags

  depends_on = [
    azurerm_network_interface.vm,
  ]
}

# Custom Script Extension to install Docker and Docker Compose
resource "azurerm_virtual_machine_extension" "docker_install" {
  name                       = "docker-install"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(file("${path.module}/scripts/install-docker.sh"))
  })

  tags = var.tags

  depends_on = [
    azurerm_linux_virtual_machine.vm,
  ]
}

