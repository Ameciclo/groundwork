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
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) v3.139.0+
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for auto-detection)
- SSH key pair
- The stack passphrase (ask an existing admin) and membership in the `TI Ameciclo` Entra ID group

State and secrets are self-managed — no Pulumi Cloud account needed. State lives in the `pulumi-state` container of the `ameciclostorprod` Azure Storage account; secrets are encrypted locally with a shared passphrase.

## ⚙️ Setup

### Step 1: Log in to the state backend

```bash
pulumi login "azblob://pulumi-state?storage_account=ameciclostorprod"
export PULUMI_CONFIG_PASSPHRASE="<ask an admin>"
pulumi stack select prod   # stack already exists — don't `stack init` a new one
```

### Step 2: Install Dependencies and Deploy

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

## 🔑 Access

TI Ameciclo group members can SSH into the VM and connect to Postgres with their own Azure AD identity instead of the shared SSH key / DB password — see [Access](../../README.md#access) in the root README.

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `coolifyPublicIp` | VM public IP address |
| `coolifySshCommand` | SSH connection command |
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


## 🔐 Database Credentials

### Getting Admin Credentials:

```bash
# PostgreSQL admin credentials
pulumi stack output postgresqlAdminUsername
pulumi stack output postgresqlAdminPassword --show-secrets
pulumi stack output postgresqlServerFqdn
```

### Creating Database Users:

The PostgreSQL server is **private** (VNet-only access). Database users must be created from the K3s VM:

**Step 1: SSH into the K3s VM**
```bash
ssh azureuser@$(pulumi stack output coolifyPublicIp)
```

**Step 2: Copy the database user creation script**
```bash
# On your local machine
scp scripts/create-database-users.sh azureuser@$(pulumi stack output coolifyPublicIp):~/
```

**Step 3: Run the script on the VM**
```bash
# On the K3s VM
chmod +x create-database-users.sh
POSTGRES_ADMIN_PASSWORD='<admin-password>' ./create-database-users.sh
```

The script will:
- ✅ Create database users: `strapi_user`, `atlas_user`, `zitadel_user`
- ✅ Generate secure random passwords
- ✅ Grant all necessary permissions
- ✅ Display credentials to save

**Step 4: Save credentials securely**

Store the generated credentials in Infisical or your secrets manager:
- `STRAPI_DB_HOST`, `STRAPI_DB_USERNAME`, `STRAPI_DB_PASSWORD`
- `ATLAS_DB_HOST`, `ATLAS_DB_USERNAME`, `ATLAS_DB_PASSWORD`
- `ZITADEL_DB_HOST`, `ZITADEL_DB_USERNAME`, `ZITADEL_DB_PASSWORD`

### Using in Kubernetes:

Create secrets from your secrets manager or manually:

```bash
# For Strapi
kubectl create secret generic strapi-db-credentials \
  --from-literal=host=ameciclo-postgres.postgres.database.azure.com \
  --from-literal=database=strapi \
  --from-literal=username=strapi_user \
  --from-literal=password='<password-from-script>' \
  -n strapi
```

### Security Benefits:

✅ **Private Network**: PostgreSQL only accessible from VNet
✅ **Secure Passwords**: Auto-generated 32-character random passwords
✅ **Encrypted Admin Password**: Stored encrypted in Pulumi state
✅ **Least Privilege**: Each app has its own database user
✅ **Manual Control**: Full control over database user creation

> 💡 **Tip**: Always run `pulumi preview` before `pulumi up`
