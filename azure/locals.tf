# Local values for DRY code and consistent naming
locals {
  # Project and environment
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  # Naming conventions
  name_prefix = "${local.project_name}-${local.environment}"

  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = local.environment
      Project     = local.project_name
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  )

  # Resource naming
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  vm_name             = "ameciclo-k3s-vm"
  postgresql_name     = var.postgresql_server_name
  storage_name        = var.storage_account_name

  # Network configuration
  vnet_address_space     = var.vnet_address_space
  database_subnet_prefix = var.database_subnet_prefix
  k3s_subnet_prefix      = "10.10.1.0/24"

  # Database configuration
  postgresql_version = var.postgresql_version
  postgresql_sku     = var.postgresql_sku_name
  postgresql_storage = var.postgresql_storage_mb

  # K3s VM configuration
  k3s_vm_size = var.k3s_vm_size
  k3s_vm_name = "ameciclo-k3s-vm"

  # K3s image configuration (Ubuntu 22.04 LTS)
  k3s_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Admin configuration
  admin_username = var.admin_username

  # Cost tracking
  cost_center = "ameciclo-infrastructure"
  cost_estimate = {
    postgresql_monthly = 24.70
    vm_monthly         = 45.00
    storage_monthly    = 1.50
    networking_monthly = 7.50
    total_monthly      = 78.70
  }
}

