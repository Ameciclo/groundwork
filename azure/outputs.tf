# K3s VM Outputs
output "k3s_vm_id" {
  description = "K3s Virtual Machine ID"
  value       = azurerm_linux_virtual_machine.k3s.id
}

output "k3s_vm_name" {
  description = "K3s Virtual Machine name"
  value       = azurerm_linux_virtual_machine.k3s.name
}

output "k3s_vm_public_ip" {
  description = "K3s Virtual Machine public IP address"
  value       = azurerm_public_ip.k3s.ip_address
}

output "k3s_vm_private_ip" {
  description = "K3s Virtual Machine private IP address"
  value       = azurerm_network_interface.k3s.private_ip_address
}

output "k3s_vm_ssh_command" {
  description = "SSH command to connect to K3s VM"
  value       = "ssh azureuser@${azurerm_public_ip.k3s.ip_address}"
}

# PostgreSQL Outputs
output "postgresql_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "postgresql_server_id" {
  description = "PostgreSQL server ID"
  value       = azurerm_postgresql_flexible_server.postgresql.id
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgresql_admin_username}:${var.postgresql_admin_password}@${azurerm_postgresql_flexible_server.postgresql.fqdn}:5432/atlas?sslmode=require"
  sensitive   = true
}

# Storage Account Outputs
# TEMPORARILY DISABLED: Storage resources disabled
# TODO: Re-enable after core infrastructure is stable
/*
output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.ameciclo.name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.ameciclo.id
}

output "storage_container_name" {
  description = "Storage container name"
  value       = azurerm_storage_container.ameciclo.name
}
*/

# Resource Group Outputs
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.ameciclo.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.ameciclo.id
}

