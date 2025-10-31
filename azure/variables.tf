# Azure Authentication
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure Client ID (Service Principal)"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure Client Secret (Service Principal)"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

# General Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ameciclo"
}

# Resource Group
variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "ameciclo-rg"
}

# Virtual Network
variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "ameciclo-vnet"
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "database_subnet_name" {
  description = "Database subnet name"
  type        = string
  default     = "database-subnet"
}

variable "database_subnet_prefix" {
  description = "Database subnet address prefix"
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

# PostgreSQL Database
variable "postgresql_server_name" {
  description = "PostgreSQL server name"
  type        = string
  default     = "ameciclo-postgres"
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "PostgreSQL SKU name (B2s Burstable tier)"
  type        = string
  default     = "B_Standard_B2s"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage in MB (32 GB)"
  type        = number
  default     = 32768
}

variable "postgresql_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "psqladmin"
  sensitive   = true
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

# Storage Account
variable "storage_account_name" {
  description = "Storage account name (must be globally unique, lowercase)"
  type        = string
  default     = "ameciclostorage"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

# Container Registry
variable "container_registry_name" {
  description = "Container Registry name (must be globally unique, lowercase)"
  type        = string
  default     = "amecicloregistry"
}

variable "container_registry_sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Standard"
}

# Virtual Machine
variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "ameciclo-vm"
}

variable "vm_size" {
  description = "VM size for compute"
  type        = string
  default     = "Standard_B2as_v2"
}

variable "vm_subnet_name" {
  description = "VM subnet name"
  type        = string
  default     = "vm-subnet"
}

variable "vm_subnet_prefix" {
  description = "VM subnet address prefix"
  type        = list(string)
  default     = ["10.10.3.0/24"]
}

variable "vm_os_disk_size_gb" {
  description = "VM OS disk size in GB"
  type        = number
  default     = 30
}

variable "vm_image_publisher" {
  description = "VM image publisher"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "VM image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  description = "VM image SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  description = "VM image version"
  type        = string
  default     = "latest"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

# K3s Configuration
variable "k3s_enabled" {
  description = "Enable K3s deployment"
  type        = bool
  default     = false
}

variable "k3s_version" {
  description = "K3s version"
  type        = string
  default     = "v1.32.4+k3s1"
}

variable "k3s_vm_size" {
  description = "VM size for K3s"
  type        = string
  default     = "Standard_B2as_v2"
}

variable "k3s_subnet_prefix" {
  description = "K3s subnet address prefix"
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "ameciclo"
    ManagedBy   = "terraform"
  }
}

# Azure Region (used by K3s)
variable "azure_region" {
  description = "Azure region for K3s deployment"
  type        = string
  default     = "westus3"
}

