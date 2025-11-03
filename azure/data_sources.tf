# Data sources for existing Azure resources
# These allow Terraform to reference existing resources without managing them

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Get current subscription
data "azurerm_subscription" "current" {}

# Get available Ubuntu 22.04 LTS image
# This ensures we always use the latest patched version
data "azurerm_image" "ubuntu" {
  name_regex          = "Ubuntu-22.04-LTS"
  resource_group_name = "UbuntuImages"
  sort_by             = "name"
  sort_order          = "Descending"

  # Fallback: if image not found, we'll use the hardcoded values in vm.tf
  # This is optional and can be removed if you prefer hardcoded values
}

# Outputs for debugging
output "current_subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Current Azure subscription ID"
}

output "current_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Current Azure tenant ID"
}

output "current_client_id" {
  value       = data.azurerm_client_config.current.client_id
  description = "Current Azure client ID"
  sensitive   = true
}

