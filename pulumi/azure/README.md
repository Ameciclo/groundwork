# Azure Infrastructure with Pulumi - Ameciclo

This directory contains Pulumi infrastructure as code (TypeScript) for provisioning Ameciclo's Azure infrastructure with K3s.

## Overview

This Pulumi program provisions the following Azure resources:

- **Resource Group** - Container for all Azure resources
- **Virtual Network** - Network isolation with subnets for K3s and database
- **Network Security Groups** - Firewall rules for network access control
- **K3s Virtual Machine** - Ubuntu 22.04 LTS VM running K3s (Standard_B2as_v2)
- **Azure Database for PostgreSQL** - Managed PostgreSQL Flexible Server with private networking
- **Private DNS Zone** - For private PostgreSQL connectivity
- **Public IP** - For K3s VM external access

## Prerequisites

- [Node.js](https://nodejs.org/) (v18 or later)
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) (v3.0 or later)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure account with appropriate permissions
- SSH key pair for VM access

## Setup

### 1. Install Dependencies

```bash
cd pulumi/azure
npm install
```

### 2. Login to Azure

```bash
az login
```

### 3. Login to Pulumi

```bash
# For Pulumi Cloud (recommended)
pulumi login

# Or for local state management
pulumi login --local
```

### 4. Create a New Stack

```bash
# Create production stack
pulumi stack init prod

# Or select existing stack
pulumi stack select prod
```

### 5. Configure the Stack

Copy the example configuration:

```bash
cp Pulumi.prod.yaml.example Pulumi.prod.yaml
```

Set required secrets:

```bash
# Set PostgreSQL admin password
pulumi config set --secret groundwork-azure:postgresql_admin_password <your-secure-password>

# Set SSH public key
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
```

### 6. Review Configuration

Edit `Pulumi.prod.yaml` to customize any non-secret values if needed.

## Deployment

### Preview Changes

```bash
pulumi preview
```

### Deploy Infrastructure

```bash
pulumi up
```

Review the changes and confirm to proceed.

### View Outputs

```bash
pulumi stack output
```

Key outputs:
- `k3sVmPublicIp` - Public IP address of the K3s VM
- `k3sVmSshCommand` - SSH command to connect to the VM
- `postgresqlServerFqdn` - PostgreSQL server FQDN
- `postgresqlConnectionString` - PostgreSQL connection string (sensitive)

## Management

### Update Infrastructure

After making changes to `index.ts`:

```bash
pulumi up
```

### Destroy Infrastructure

```bash
pulumi destroy
```

### View Stack State

```bash
pulumi stack
```

### Export Stack State

```bash
pulumi stack export > stack-backup.json
```

## Configuration Reference

All configuration values can be set in `Pulumi.prod.yaml` or via CLI:

```bash
pulumi config set groundwork-azure:<key> <value>
```

### Available Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `environment` | Environment name | `production` |
| `project_name` | Project name for resource naming | `ameciclo` |
| `resource_group_name` | Resource group name | `ameciclo-rg` |
| `vnet_name` | Virtual network name | `ameciclo-vnet` |
| `postgresql_server_name` | PostgreSQL server name | Required |
| `postgresql_admin_username` | PostgreSQL admin username | Required |
| `postgresql_admin_password` | PostgreSQL admin password (secret) | Required |
| `admin_ssh_public_key` | SSH public key for VM (secret) | Required |
| `k3s_vm_size` | VM size for K3s | `Standard_B2as_v2` |

## Migrating from Terraform

This Pulumi configuration is equivalent to the Terraform configuration in `../../azure/`.

### Key Differences

1. **State Management**: Pulumi uses its own state backend (Pulumi Cloud or local)
2. **Language**: TypeScript instead of HCL
3. **Secrets**: Pulumi encrypts secrets in the state file
4. **Outputs**: Accessed via `pulumi stack output` instead of `terraform output`

### Migration Steps

1. Export Terraform state and resources
2. Deploy Pulumi infrastructure to a new stack
3. Migrate workloads to new infrastructure
4. Destroy old Terraform infrastructure

## Troubleshooting

### Authentication Issues

```bash
az login
az account show
```

### State Issues

```bash
pulumi stack export > backup.json
pulumi stack import < backup.json
```

### Resource Conflicts

If resources already exist, you may need to import them:

```bash
pulumi import azure-native:resources:ResourceGroup ameciclo /subscriptions/{subscription-id}/resourceGroups/ameciclo-rg
```

## Cost Estimation

Approximate monthly costs (West US 3 region):

- K3s VM (Standard_B2as_v2): ~$45/month
- PostgreSQL (B_Standard_B2s): ~$25/month
- Networking: ~$8/month
- **Total**: ~$78/month

## Support

For issues or questions, please refer to:
- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [Azure Native Provider](https://www.pulumi.com/registry/packages/azure-native/)

