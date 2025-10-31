resource "azurerm_resource_group" "ameciclo" {
  name     = var.resource_group_name
  location = var.region

  tags = var.tags
}

