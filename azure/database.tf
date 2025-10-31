# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.ameciclo.name

  tags = var.tags
}

# Link Private DNS Zone to main Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_main" {
  name                  = "postgresql-vnet-link-main"
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.ameciclo.id
  resource_group_name   = azurerm_resource_group.ameciclo.name
  registration_enabled  = false

  tags = var.tags
}

# Link Private DNS Zone to K3s Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_k3s" {
  name                  = "postgresql-vnet-link-k3s"
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.k3s.id
  resource_group_name   = azurerm_resource_group.ameciclo.name
  registration_enabled  = false

  tags = var.tags
}

# Azure Database for PostgreSQL - Flexible Server
# Configuration: B2s Burstable tier
# - 2 vCores (burstable)
# - 4 GB RAM
# - 32 GB storage
# - Cost: ~$24.70/month
# - Perfect for Kong, Atlas, Kestra
resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                   = var.postgresql_server_name
  location               = azurerm_resource_group.ameciclo.location
  resource_group_name    = azurerm_resource_group.ameciclo.name
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password
  version                = var.postgresql_version
  sku_name               = var.postgresql_sku_name
  storage_mb             = var.postgresql_storage_mb
  zone                   = "1"

  delegated_subnet_id           = azurerm_subnet.database.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  public_network_access_enabled = false

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql_main,
    azurerm_private_dns_zone_virtual_network_link.postgresql_k3s
  ]
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "atlas" {
  name      = "atlas"
  server_id = azurerm_postgresql_flexible_server.postgresql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "kong" {
  name      = "kong"
  server_id = azurerm_postgresql_flexible_server.postgresql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Private DNS A Record for PostgreSQL
# This maps the private endpoint hostname to the private IP address
resource "azurerm_private_dns_a_record" "postgresql" {
  name                = "ameciclo-postgres"
  zone_name           = azurerm_private_dns_zone.postgresql.name
  resource_group_name = azurerm_resource_group.ameciclo.name
  ttl                 = 300
  records             = ["10.10.2.4"]
}

# Note: Firewall rules are not needed when using private endpoints
# PostgreSQL is only accessible through the private DNS zone within the VNets

