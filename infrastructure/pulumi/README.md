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
- Azure Service Principal
- SSH key pair
- Pulumi Cloud account (for ESC environments)

## ⚙️ Setup

### Step 1: Create Pulumi ESC Environment

Pulumi ESC (Environments, Secrets, and Configuration) centralizes all your secrets and configuration.

1. **Login to Pulumi Cloud:**
   ```bash
   pulumi login
   ```

2. **Create the ESC environment:**
   ```bash
   # Create the environment
   pulumi env init <your-org>/infrastructure-prod

   # Edit the environment
   pulumi env edit <your-org>/infrastructure-prod
   ```

3. **Copy the contents from `esc/prod.yaml` into the environment editor**

4. **Update the placeholder values:**
   - Replace `ssh.publicKey` with your actual SSH public key:
     ```bash
     cat ~/.ssh/id_rsa.pub
     ```

5. **Save the environment**

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


## 🔐 Database Credentials

Pulumi automatically creates database users and generates secure passwords.

### Getting Credentials:

```bash
# PostgreSQL admin credentials
pulumi stack output postgresqlAdminUsername
pulumi stack output postgresqlAdminPassword --show-secrets

# Application database user credentials
pulumi stack output strapiDbUsername
pulumi stack output strapiDbPassword --show-secrets

pulumi stack output atlasDbUsername
pulumi stack output atlasDbPassword --show-secrets

pulumi stack output zitadelDbUsername
pulumi stack output zitadelDbPassword --show-secrets
```

### Using in Kubernetes:

Create secrets directly from Pulumi outputs:

```bash
# For Strapi
kubectl create secret generic strapi-db-credentials \
  --from-literal=host=$(pulumi stack output postgresqlServerFqdn) \
  --from-literal=database=strapi \
  --from-literal=username=$(pulumi stack output strapiDbUsername) \
  --from-literal=password=$(pulumi stack output strapiDbPassword --show-secrets) \
  -n strapi

# For Atlas
kubectl create secret generic atlas-db-credentials \
  --from-literal=host=$(pulumi stack output postgresqlServerFqdn) \
  --from-literal=database=atlas \
  --from-literal=username=$(pulumi stack output atlasDbUsername) \
  --from-literal=password=$(pulumi stack output atlasDbPassword --show-secrets) \
  -n atlas

# For Zitadel
kubectl create secret generic zitadel-db-credentials \
  --from-literal=host=$(pulumi stack output postgresqlServerFqdn) \
  --from-literal=database=zitadel \
  --from-literal=username=$(pulumi stack output zitadelDbUsername) \
  --from-literal=password=$(pulumi stack output zitadelDbPassword --show-secrets) \
  -n zitadel
```

### Or Store in Infisical:

1. Get credentials using `pulumi stack output`
2. Store in Infisical:
   - `STRAPI_DB_HOST`, `STRAPI_DB_USERNAME`, `STRAPI_DB_PASSWORD`
   - `ATLAS_DB_HOST`, `ATLAS_DB_USERNAME`, `ATLAS_DB_PASSWORD`
   - `ZITADEL_DB_HOST`, `ZITADEL_DB_USERNAME`, `ZITADEL_DB_PASSWORD`
3. Use External Secrets Operator to sync to Kubernetes

### Security Benefits:

✅ **Fully Automated**: Database users created automatically
✅ **Secure Passwords**: Auto-generated 32-character random passwords
✅ **Encrypted Storage**: All passwords stored encrypted in Pulumi state
✅ **Least Privilege**: Each app has its own database user
✅ **Declarative**: Infrastructure as Code for database access control
✅ **Centralized Secrets**: ESC manages all configuration and secrets

> 💡 **Tip**: Always run `pulumi preview` before `pulumi up`
