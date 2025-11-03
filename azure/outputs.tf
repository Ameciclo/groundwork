# VM Outputs
output "vm_id" {
  description = "Virtual Machine ID"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  description = "Virtual Machine public IP address"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_private_ip" {
  description = "Virtual Machine private IP address"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
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

# Resource Group Outputs
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.ameciclo.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.ameciclo.id
}

