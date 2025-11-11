# Quick Start Guide - Pulumi Azure Infrastructure

## Prerequisites Checklist

- [ ] Node.js v18+ installed
- [ ] Pulumi CLI installed
- [ ] Azure CLI installed and logged in (`az login`)
- [ ] SSH key pair generated
- [ ] PostgreSQL admin password ready

## Installation (5 minutes)

### 1. Install Pulumi CLI

**macOS:**
```bash
brew install pulumi
```

**Linux:**
```bash
curl -fsSL https://get.pulumi.com | sh
```

**Windows:**
```powershell
choco install pulumi
```

### 2. Verify Installation

```bash
pulumi version
node --version
az --version
```

## Setup (10 minutes)

### 1. Navigate to Directory

```bash
cd pulumi/azure
```

### 2. Install Dependencies

```bash
npm install
# or use make
make install
```

### 3. Login to Pulumi

**Option A: Pulumi Cloud (Recommended)**
```bash
pulumi login
```

**Option B: Local State**
```bash
pulumi login --local
```

### 4. Create Stack

```bash
pulumi stack init prod
```

### 5. Configure Stack

```bash
# Set secrets
pulumi config set --secret groundwork-azure:postgresql_admin_password "YourSecurePassword123!"
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"

# Set required values
pulumi config set groundwork-azure:postgresql_server_name "ameciclo-postgres"
pulumi config set groundwork-azure:postgresql_admin_username "psqladmin"

# Optional: customize other values
pulumi config set azure-native:location westus3
pulumi config set groundwork-azure:environment production
```

## Deployment (15-20 minutes)

### 1. Preview Changes

```bash
pulumi preview
# or use make
make preview
```

Review the resources that will be created.

### 2. Deploy Infrastructure

```bash
pulumi up
# or use make
make up
```

Type "yes" to confirm deployment.

### 3. View Outputs

```bash
pulumi stack output
# or use make
make output
```

## Common Commands

### View Stack Information

```bash
pulumi stack                    # Show current stack info
pulumi stack output             # Show all outputs
pulumi stack output k3sVmPublicIp  # Show specific output
```

### Update Infrastructure

```bash
# After editing index.ts
npm run build
pulumi preview
pulumi up
```

### Refresh State

```bash
pulumi refresh
```

### Destroy Infrastructure

```bash
pulumi destroy
# or use make
make destroy
```

### Export/Import State

```bash
# Export
pulumi stack export > backup.json

# Import
pulumi stack import < backup.json
```

## Quick Reference

### Configuration Commands

```bash
# List all config
pulumi config

# Get a value
pulumi config get groundwork-azure:environment

# Set a value
pulumi config set groundwork-azure:environment staging

# Set a secret
pulumi config set --secret groundwork-azure:api_key "secret-value"

# Remove a value
pulumi config rm groundwork-azure:environment
```

### Stack Commands

```bash
# List stacks
pulumi stack ls

# Select stack
pulumi stack select prod

# Create new stack
pulumi stack init dev

# Delete stack
pulumi stack rm dev
```

### Resource Commands

```bash
# List resources
pulumi stack --show-urns

# Show resource details
pulumi stack --show-ids

# Import existing resource
pulumi import azure-native:resources:ResourceGroup ameciclo /subscriptions/{sub}/resourceGroups/ameciclo-rg
```

## Outputs Reference

After deployment, you'll have these outputs:

| Output | Description | Example |
|--------|-------------|---------|
| `k3sVmPublicIp` | Public IP of K3s VM | `20.123.45.67` |
| `k3sVmPrivateIp` | Private IP of K3s VM | `10.10.1.4` |
| `k3sVmSshCommand` | SSH command to connect | `ssh azureuser@20.123.45.67` |
| `postgresqlServerFqdn` | PostgreSQL FQDN | `ameciclo-postgres.postgres.database.azure.com` |
| `resourceGroupName` | Resource group name | `ameciclo-rg` |

## Accessing Resources

### SSH to K3s VM

```bash
# Get SSH command
pulumi stack output k3sVmSshCommand

# Or manually
ssh azureuser@$(pulumi stack output k3sVmPublicIp)
```

### Connect to PostgreSQL

```bash
# Get connection string (sensitive)
pulumi stack output postgresqlConnectionString --show-secrets

# Or manually
psql "postgresql://psqladmin:PASSWORD@$(pulumi stack output postgresqlServerFqdn):5432/atlas?sslmode=require"
```

## Troubleshooting

### Authentication Issues

```bash
# Re-login to Azure
az login
az account show

# Verify Pulumi login
pulumi whoami
```

### State Issues

```bash
# Refresh state from cloud
pulumi refresh

# Export state for backup
pulumi stack export > backup-$(date +%Y%m%d).json
```

### Build Issues

```bash
# Clean and rebuild
make clean
make install
make build
```

### Resource Conflicts

```bash
# If resource already exists, import it
pulumi import <type> <name> <id>

# Example
pulumi import azure-native:resources:ResourceGroup ameciclo /subscriptions/xxx/resourceGroups/ameciclo-rg
```

## Next Steps

1. ✅ Infrastructure deployed
2. 📝 Save outputs: `pulumi stack output > outputs.txt`
3. 🔐 Configure K3s on the VM (see `../../ansible/k3s-bootstrap-playbook.yml`)
4. 🚀 Deploy applications using ArgoCD
5. 📊 Set up monitoring and alerts

## Getting Help

- 📖 Full documentation: [README.md](README.md)
- 🔄 Migration guide: [MIGRATION.md](MIGRATION.md)
- 🌐 Pulumi docs: https://www.pulumi.com/docs/
- 💬 Pulumi Slack: https://slack.pulumi.com/

## Useful Make Commands

```bash
make help       # Show all available commands
make install    # Install dependencies
make build      # Build TypeScript
make preview    # Preview changes
make up         # Deploy infrastructure
make output     # Show outputs
make destroy    # Destroy infrastructure
make clean      # Clean build artifacts
```

