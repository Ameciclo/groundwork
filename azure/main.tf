terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  # Using Terraform Cloud
  cloud {
    organization = "Ameciclo"

    workspaces {
      name = "groundwork-azure"
    }
  }

  # Local backend (disabled - using Terraform Cloud)
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# COMMENTED OUT - Will enable after database is created
# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
# }

# provider "helm" {
#   kubernetes {
#     host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
#     client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
#     client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
#     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
#   }
# }

