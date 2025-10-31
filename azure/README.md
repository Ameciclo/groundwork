# Azure Infrastructure - Ameciclo

This directory contains Terraform configuration for provisioning Ameciclo's infrastructure on Microsoft Azure using AKS (Azure Kubernetes Service).

## Overview

This setup provisions the following Azure resources:

- **Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster for container orchestration
- **Azure Database for PostgreSQL** - Managed PostgreSQL database with private networking
- **Azure Storage Account** - Blob storage for application data (equivalent to DigitalOcean Spaces)
- **Azure Container Registry** - Private container image registry
- **Virtual Network** - Network isolation with subnets for AKS and database
- **Network Security Groups** - Firewall rules for network access control

## Prerequisites

### 1. Azure Account Setup

- Azure subscription with appropriate permissions
- Azure CLI installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

### 2. Service Principal Creation

Create a Service Principal for Terraform:

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

This will output:
```json
{
  "appId": "your-client-id",
  "displayName": "azure-cli-...",
  "password": "your-client-secret",
  "tenant": "your-tenant-id"
}
```

### 3. Terraform Setup

- Terraform v1.0.0 or later: https://www.terraform.io/downloads.html
- Terraform Cloud account (for remote state)

### 4. kubectl Installation

```bash
az aks install-cli
```

## Configuration

### 1. Create terraform.tfvars

Copy the example file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your Azure credentials and configuration:

```hcl
azure_subscription_id = "your-subscription-id"
azure_client_id       = "your-client-id"
azure_client_secret   = "your-client-secret"
azure_tenant_id       = "your-tenant-id"
```

**Important:** Never commit `terraform.tfvars` to version control!

### 2. Storage Account Name

The storage account name must be globally unique and lowercase (3-24 characters):

```hcl
storage_account_name = "ameciclostorage"  # Change to something unique
```

### 3. Container Registry Name

The container registry name must be globally unique and lowercase (5-50 characters):

```hcl
container_registry_name = "amecicloregistry"  # Change to something unique
```

## Deployment

### 1. Initialize Terraform

```bash
cd azure
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the plan to ensure all resources are correct.

### 3. Apply the Configuration

```bash
terraform apply tfplan
```

This will take approximately 10-15 minutes to complete.

### 4. Get Kubeconfig

After deployment, get your kubeconfig:

```bash
az aks get-credentials --resource-group ameciclo-rg --name ameciclo-aks
```

Or use the generated kubeconfig:

```bash
export KUBECONFIG=$(pwd)/kubeconfig.yaml
```

### 5. Verify Cluster Access

```bash
kubectl cluster-info
kubectl get nodes
```

## Resource Mapping

| DigitalOcean | Azure |
|--------------|-------|
| Droplets | AKS Nodes |
| PostgreSQL Database | Azure Database for PostgreSQL |
| Spaces (S3) | Azure Blob Storage |
| VPC | Azure Virtual Network |
| Firewall Rules | Network Security Groups |

## Networking

### Subnets

- **AKS Subnet** (10.10.1.0/24): Hosts AKS nodes
- **Database Subnet** (10.10.2.0/24): Hosts PostgreSQL (private, no internet access)

### Security

- PostgreSQL is deployed in a private subnet with no public internet access
- AKS nodes can communicate with PostgreSQL via private DNS
- Storage account access is restricted to AKS subnet
- Network Security Groups enforce inbound/outbound rules

## Database Connection

### From AKS Pods

Connection string (use in Kubernetes secrets):

```
postgresql://psqladmin:PASSWORD@ameciclo-postgres.postgres.database.azure.com:5432/atlas?sslmode=require
```

### From Local Machine

To connect from your local machine, you need to:

1. Create a private endpoint or use Azure Bastion
2. Or temporarily allow your IP in the firewall rules

## Container Registry

### Login to Registry

```bash
az acr login --name amecicloregistry
```

### Push Images

```bash
docker tag myimage:latest amecicloregistry.azurecr.io/myimage:latest
docker push amecicloregistry.azurecr.io/myimage:latest
```

## Scaling

### Auto-scaling

AKS is configured with auto-scaling:
- Minimum nodes: 2
- Maximum nodes: 5

Nodes will automatically scale based on resource requests.

### Manual Scaling

```bash
az aks scale --resource-group ameciclo-rg --name ameciclo-aks --node-count 3
```

## Monitoring

### View Cluster Metrics

```bash
az aks show --resource-group ameciclo-rg --name ameciclo-aks
```

### Enable Azure Monitor

```bash
az aks enable-addons --resource-group ameciclo-rg --name ameciclo-aks --addons monitoring
```

## Cost Optimization

- **VM Size**: Currently using `Standard_B2s` (burstable). Adjust based on workload.
- **Node Count**: Start with 2 nodes, scale up as needed.
- **Storage**: Using LRS (Locally Redundant Storage). Consider GRS for production.
- **Database**: Using B_Standard_B1ms. Upgrade for production workloads.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the database. Ensure you have backups!

## Troubleshooting

### AKS Cluster Not Accessible

```bash
az aks get-credentials --resource-group ameciclo-rg --name ameciclo-aks --overwrite-existing
```

### PostgreSQL Connection Issues

Check firewall rules:

```bash
az postgres flexible-server firewall-rule list --resource-group ameciclo-rg --name ameciclo-postgres
```

### Container Registry Issues

Check authentication:

```bash
az acr login --name amecicloregistry
```

## Next Steps

1. Deploy Kubernetes manifests for your services
2. Set up Ingress controller for routing
3. Configure monitoring and logging
4. Set up CI/CD pipelines
5. Migrate data from DigitalOcean PostgreSQL

## References

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

