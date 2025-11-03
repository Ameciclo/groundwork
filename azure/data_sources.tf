# Data sources for existing Azure resources
# These allow Terraform to reference existing resources without managing them

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Get current subscription
data "azurerm_subscription" "current" {}

# Note: Ubuntu image data source - can be used for future reference
# Currently using latest Ubuntu 22.04 LTS from Canonical publisher
# The azurerm_image data source is not used in this configuration
# as we reference the image directly from the Canonical publisher

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

