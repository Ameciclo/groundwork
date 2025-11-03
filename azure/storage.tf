# Storage Account (for Blob Storage - equivalent to DigitalOcean Spaces)
# Used for backups, exports, and file uploads
# TEMPORARILY DISABLED: Network rules causing access issues
# TODO: Re-enable after core infrastructure is stable
/*
resource "azurerm_storage_account" "ameciclo" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.ameciclo.name
  location                 = azurerm_resource_group.ameciclo.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = var.tags
}

# Storage Container (for backups and exports)
# Note: storage_account_name is deprecated in favor of storage_account_id in azurerm v5.0+
# Currently using storage_account_name for compatibility with azurerm v4.51.0
resource "azurerm_storage_container" "ameciclo" {
  name                  = "ameciclo-data"
  storage_account_name  = azurerm_storage_account.ameciclo.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.ameciclo]
}

# Storage Account Network Rules (restrict to K3s subnet)
# IMPORTANT: Create container BEFORE applying network rules to avoid access denied errors
resource "azurerm_storage_account_network_rules" "ameciclo" {
  storage_account_id         = azurerm_storage_account.ameciclo.id
  default_action             = "Deny"
  bypass                     = ["AzureServices", "Logging", "Metrics"]
  virtual_network_subnet_ids = [azurerm_subnet.k3s.id]

  depends_on = [azurerm_storage_container.ameciclo]
}
*/

