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


## 🔐 Database Users Setup

Pulumi creates the databases, but you need to manually create database users for security and flexibility.

### Step 1: Run the Setup Script

After deploying with Pulumi, create dedicated database users:

```bash
# SSH into the K3s VM
ssh azureuser@$(pulumi stack output k3sPublicIp)

# Run the database user setup script
cd /path/to/groundwork/infrastructure/pulumi/scripts
POSTGRES_ADMIN_PASSWORD='your-admin-password' ./setup-database-users.sh
```

This creates:
- **`strapi_user`** - Full access to `strapi` database
- **`atlas_user`** - Full access to `atlas` database
- **`zitadel_user`** - Full access to `zitadel` database

### Step 2: Store Credentials in Infisical

The script outputs the generated passwords. Store them securely in Infisical:

1. Go to your Infisical project
2. Add these secrets:
   - `STRAPI_DB_USERNAME` = `strapi_user`
   - `STRAPI_DB_PASSWORD` = `<generated-password>`
   - `ATLAS_DB_USERNAME` = `atlas_user`
   - `ATLAS_DB_PASSWORD` = `<generated-password>`
   - `ZITADEL_DB_USERNAME` = `zitadel_user`
   - `ZITADEL_DB_PASSWORD` = `<generated-password>`

### Step 3: Reference in Kubernetes

Use Infisical's External Secrets Operator to sync credentials to Kubernetes:

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: strapi-db-credentials
  namespace: strapi
spec:
  # ... Infisical config ...
  managedKubeSecretReferences:
    - secretName: strapi-db-credentials
      template:
        data:
          username: "{{ .STRAPI_DB_USERNAME }}"
          password: "{{ .STRAPI_DB_PASSWORD }}"
```

### Security Benefits:

✅ **Separation of Concerns**: Infrastructure (Pulumi) separate from credentials (Infisical)
✅ **Credential Rotation**: Easy to rotate passwords independently
✅ **Centralized Secrets**: All credentials in one secure location
✅ **Audit Trail**: Infisical tracks all secret access
✅ **Least Privilege**: Each app only accesses its own database

> 💡 **Tip**: Always run `pulumi preview` before `pulumi up`
