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
  vnet_address_space       = var.vnet_address_space
  vm_subnet_prefix         = var.vm_subnet_prefix
  database_subnet_prefix   = var.database_subnet_prefix
  k3s_subnet_prefix        = var.k3s_subnet_prefix

  # Database configuration
  postgresql_version = var.postgresql_version
  postgresql_sku     = var.postgresql_sku_name
  postgresql_storage = var.postgresql_storage_mb

  # VM configuration
  vm_size = var.vm_size
  vm_os_disk_size = var.vm_os_disk_size_gb

  # Image configuration
  vm_image = {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  # Admin configuration
  admin_username = var.admin_username

  # K3s configuration
  k3s_enabled = var.k3s_enabled
  k3s_version = var.k3s_version
  k3s_region  = var.azure_region

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

