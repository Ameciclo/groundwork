# COMMENTED OUT - Will enable after database is created
# # Azure Container Registry
# resource "azurerm_container_registry" "acr" {
#   name                = var.container_registry_name
#   resource_group_name = azurerm_resource_group.ameciclo.name
#   location            = azurerm_resource_group.ameciclo.location
#   sku                 = var.container_registry_sku
#   admin_enabled       = false
#
#   tags = var.tags
# }

