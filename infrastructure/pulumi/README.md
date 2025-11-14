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
  - Admin password: auto-generated secure random password
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


## 🔐 PostgreSQL Admin Credentials

Pulumi automatically generates a secure random password for the PostgreSQL admin user.

### Getting Admin Credentials:

```bash
# View PostgreSQL admin credentials
pulumi stack output postgresqlAdminUsername
pulumi stack output postgresqlAdminPassword --show-secrets
```

### Creating Database Users:

After deployment, SSH into the K3s VM and create dedicated database users:

```bash
# SSH into the VM
ssh azureuser@$(pulumi stack output k3sPublicIp)

# Get the admin password
ADMIN_PASSWORD=$(pulumi stack output postgresqlAdminPassword --show-secrets)

# Create database users
PGSSLMODE=require PGPASSWORD="$ADMIN_PASSWORD" psql \
  -h $(pulumi stack output postgresqlServerFqdn) \
  -U psqladmin \
  -d postgres \
  -c "CREATE USER strapi_user WITH PASSWORD 'your-secure-password';"

# Grant permissions
PGSSLMODE=require PGPASSWORD="$ADMIN_PASSWORD" psql \
  -h $(pulumi stack output postgresqlServerFqdn) \
  -U psqladmin \
  -d strapi \
  -c "GRANT ALL PRIVILEGES ON DATABASE strapi TO strapi_user;"
```

Repeat for `atlas_user` and `zitadel_user`.

### Store Credentials in Infisical:

1. Create database users with secure passwords
2. Store credentials in Infisical:
   - `STRAPI_DB_USERNAME` / `STRAPI_DB_PASSWORD`
   - `ATLAS_DB_USERNAME` / `ATLAS_DB_PASSWORD`
   - `ZITADEL_DB_USERNAME` / `ZITADEL_DB_PASSWORD`
3. Use External Secrets Operator to sync to Kubernetes

### Security Benefits:

✅ **Auto-Generated Admin Password**: Secure 32-character random password
✅ **Encrypted Storage**: Password stored encrypted in Pulumi state
✅ **Manual User Creation**: Full control over database user permissions
✅ **Separation of Concerns**: Infrastructure separate from application credentials

> 💡 **Tip**: Always run `pulumi preview` before `pulumi up`
