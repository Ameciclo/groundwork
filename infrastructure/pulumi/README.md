# Azure Infrastructure - Pulumi

Pulumi TypeScript code for deploying Ameciclo's Azure infrastructure.

## 🚀 Quick Start

```bash
# 1. Login to Azure (to auto-detect credentials)
az login

# 2. Run setup script
./scripts/setup.sh

# 3. Preview changes (dry run)
pulumi preview

# 4. Deploy infrastructure
pulumi up
```

## 🏗️ What Gets Created

- **Virtual Network** (`10.10.0.0/16`) with K3s and database subnets
- **PostgreSQL** (Standard_B2s) with private networking
  - Databases: `atlas`, `strapi`, `zitadel`
  - Dedicated users: `atlas_user`, `strapi_user`, `zitadel_user` (auto-created)
- **K3s VM** (Standard_B2as_v2) with Ubuntu 22.04 LTS
- **Security Groups** for SSH, HTTP, HTTPS access
- **Private DNS** for database connectivity
- **Storage Account** with Blob Storage containers (media, backups, logs)

## 📋 Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for auto-detection)
- Azure Service Principal
- SSH key pair

## ⚙️ Setup

### Automated Setup (Recommended)

The setup script will auto-detect your Azure credentials if you're logged in:

```bash
# Login to Azure
az login

# Run setup script (auto-detects Subscription ID & Tenant ID)
./scripts/setup.sh
```

### Getting Azure Credentials

**Create a Service Principal:**
```bash
az ad sp create-for-rbac --name "pulumi-ameciclo" --role Contributor

# Outputs:
# {
#   "appId": "YOUR_CLIENT_ID",
#   "password": "YOUR_CLIENT_SECRET",
#   "tenant": "YOUR_TENANT_ID"
# }
```

**Get Tenant ID:**
```bash
az account show --query tenantId -o tsv
```

### Manual Configuration

<details>
<summary>Click to expand manual configuration steps</summary>

```bash
# Install dependencies
npm install

# Azure authentication
pulumi config set azure-native:subscriptionId --secret YOUR_SUBSCRIPTION_ID
pulumi config set azure-native:clientId --secret YOUR_CLIENT_ID
pulumi config set azure-native:clientSecret --secret YOUR_CLIENT_SECRET
pulumi config set azure-native:tenantId --secret YOUR_TENANT_ID

# Database credentials
pulumi config set postgresqlAdminUsername --secret YOUR_DB_USERNAME
pulumi config set postgresqlAdminPassword --secret YOUR_DB_PASSWORD

# SSH key
pulumi config set adminSshPublicKey --secret "$(cat ~/.ssh/id_rsa.pub)"
```

</details>

## 🔧 Customization

```bash
# Custom project name
pulumi config set projectName my-project

# Different Azure region
pulumi config set azure-native:location westus2

# Environment tag
pulumi config set environment staging
```

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `k3sPublicIp` | VM public IP address |
| `k3sSshCommand` | SSH connection command |
| `postgresqlServerFqdn` | Database server FQDN |
| `resourceGroupName` | Azure resource group |

## 💰 Cost Estimate

| Resource | Monthly Cost |
|----------|--------------|
| PostgreSQL (Standard_B2s) | ~$25 |
| VM (Standard_B2as_v2) | ~$45 |
| Storage | ~$2 |
| Networking | ~$8 |
| **Total** | **~$80** |

## 🛠️ Common Commands

```bash
# Preview changes (dry run)
pulumi preview                    # See what will change
pulumi preview --diff            # Show detailed differences

# Deploy
pulumi up                        # Deploy infrastructure
pulumi stack output              # View outputs (IPs, FQDNs, etc.)

# Manage
pulumi stack history             # View deployment history
pulumi destroy                   # ⚠️ Delete everything
```


## 🔐 Database Users & Credentials

Pulumi automatically creates dedicated database users for each application with secure random passwords:

### Created Users:
- **`strapi_user`** - Full access to `strapi` database
- **`atlas_user`** - Full access to `atlas` database
- **`zitadel_user`** - Full access to `zitadel` database

### Getting Credentials:

```bash
# View all database credentials (passwords are encrypted)
pulumi stack output

# Get specific credentials
pulumi stack output strapiDbUsername
pulumi stack output strapiDbPassword --show-secrets

pulumi stack output atlasDbUsername
pulumi stack output atlasDbPassword --show-secrets

pulumi stack output zitadelDbUsername
pulumi stack output zitadelDbPassword --show-secrets
```

### Security Benefits:

✅ **Isolation**: Each app can only access its own database
✅ **Least Privilege**: Users have only necessary permissions
✅ **Secure Passwords**: Auto-generated 32-character random passwords
✅ **Encrypted Storage**: Passwords stored encrypted in Pulumi state
✅ **Audit Trail**: Clear tracking of which app accesses what

### Using in Kubernetes:

Create secrets with the credentials:

```bash
# For Strapi
kubectl create secret generic strapi-db-credentials \
  --from-literal=username=$(pulumi stack output strapiDbUsername) \
  --from-literal=password=$(pulumi stack output strapiDbPassword --show-secrets) \
  -n strapi

# For Atlas
kubectl create secret generic atlas-db-credentials \
  --from-literal=username=$(pulumi stack output atlasDbUsername) \
  --from-literal=password=$(pulumi stack output atlasDbPassword --show-secrets) \
  -n atlas

# For Zitadel
kubectl create secret generic zitadel-db-credentials \
  --from-literal=username=$(pulumi stack output zitadelDbUsername) \
  --from-literal=password=$(pulumi stack output zitadelDbPassword --show-secrets) \
  -n zitadel
```

> 💡 **Tip**: Always run `pulumi preview` before `pulumi up`
