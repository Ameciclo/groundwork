# Migration Guide: Terraform to Pulumi

This guide helps you migrate from the Terraform configuration in `../../azure/` to this Pulumi setup.

## Overview

The Pulumi configuration in this directory is a complete port of the Terraform configuration, providing the same infrastructure with these benefits:

- **Type Safety**: TypeScript provides compile-time type checking
- **Better IDE Support**: IntelliSense, auto-completion, and inline documentation
- **Familiar Language**: Use TypeScript/JavaScript instead of HCL
- **Integrated Testing**: Write tests in the same language as your infrastructure
- **Secrets Management**: Built-in encryption for sensitive values

## Resource Mapping

| Terraform Resource | Pulumi Resource | Notes |
|-------------------|-----------------|-------|
| `azurerm_resource_group.ameciclo` | `azure.resources.ResourceGroup("ameciclo")` | Same configuration |
| `azurerm_virtual_network.ameciclo` | `azure.network.VirtualNetwork("ameciclo-vnet")` | Same configuration |
| `azurerm_subnet.k3s` | `azure.network.Subnet("k3s-subnet")` | Same configuration |
| `azurerm_subnet.database` | `azure.network.Subnet("database-subnet")` | Same configuration |
| `azurerm_network_security_group.k3s` | `azure.network.NetworkSecurityGroup("k3s-nsg")` | Same configuration |
| `azurerm_network_security_group.database` | `azure.network.NetworkSecurityGroup("database-nsg")` | Same configuration |
| `azurerm_linux_virtual_machine.k3s` | `azure.compute.VirtualMachine("k3s-vm")` | Same configuration |
| `azurerm_postgresql_flexible_server.postgresql` | `azure.dbforpostgresql.Server("postgresql-server")` | Same configuration |
| `azurerm_private_dns_zone.postgresql` | `azure.network.PrivateZone("postgresql-dns-zone")` | Same configuration |

## Migration Strategies

### Strategy 1: Blue-Green Deployment (Recommended)

Deploy new infrastructure alongside existing, then migrate:

1. **Deploy Pulumi Stack**
   ```bash
   cd pulumi/azure
   npm install
   pulumi stack init prod-new
   pulumi config set --secret groundwork-azure:postgresql_admin_password <password>
   pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
   pulumi up
   ```

2. **Migrate Data**
   - Export data from old PostgreSQL
   - Import to new PostgreSQL
   - Update DNS/load balancers

3. **Verify New Infrastructure**
   - Test all services
   - Verify connectivity
   - Check monitoring

4. **Destroy Old Infrastructure**
   ```bash
   cd ../../azure
   terraform destroy
   ```

### Strategy 2: Import Existing Resources

Import existing Terraform-managed resources into Pulumi:

1. **Identify Resources**
   ```bash
   cd ../../azure
   terraform state list
   ```

2. **Import into Pulumi**
   ```bash
   cd ../pulumi/azure
   pulumi import azure-native:resources:ResourceGroup ameciclo /subscriptions/{sub-id}/resourceGroups/ameciclo-rg
   pulumi import azure-native:network:VirtualNetwork ameciclo-vnet /subscriptions/{sub-id}/resourceGroups/ameciclo-rg/providers/Microsoft.Network/virtualNetworks/ameciclo-vnet
   # ... continue for all resources
   ```

3. **Remove from Terraform**
   ```bash
   cd ../../azure
   terraform state rm azurerm_resource_group.ameciclo
   terraform state rm azurerm_virtual_network.ameciclo
   # ... continue for all resources
   ```

### Strategy 3: Fresh Deployment

If you can afford downtime:

1. **Backup Data**
   ```bash
   # Backup PostgreSQL databases
   pg_dump -h <old-server> -U psqladmin atlas > atlas_backup.sql
   pg_dump -h <old-server> -U psqladmin kong > kong_backup.sql
   ```

2. **Destroy Terraform Infrastructure**
   ```bash
   cd ../../azure
   terraform destroy
   ```

3. **Deploy Pulumi Infrastructure**
   ```bash
   cd ../pulumi/azure
   pulumi up
   ```

4. **Restore Data**
   ```bash
   psql -h <new-server> -U psqladmin atlas < atlas_backup.sql
   psql -h <new-server> -U psqladmin kong < kong_backup.sql
   ```

## Configuration Migration

### Terraform Variables → Pulumi Config

| Terraform Variable | Pulumi Config Key |
|-------------------|-------------------|
| `azure_subscription_id` | Set via `az login` |
| `azure_client_id` | Set via `az login` |
| `azure_client_secret` | Set via `az login` |
| `azure_tenant_id` | Set via `az login` |
| `environment` | `groundwork-azure:environment` |
| `region` | `azure-native:location` |
| `project_name` | `groundwork-azure:project_name` |
| `resource_group_name` | `groundwork-azure:resource_group_name` |
| `postgresql_admin_password` | `groundwork-azure:postgresql_admin_password` (secret) |
| `admin_ssh_public_key` | `groundwork-azure:admin_ssh_public_key` (secret) |

### Setting Pulumi Config

```bash
# Non-secret values
pulumi config set groundwork-azure:environment production
pulumi config set azure-native:location westus3

# Secret values
pulumi config set --secret groundwork-azure:postgresql_admin_password <password>
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
```

## State Management

### Terraform State

Terraform uses Terraform Cloud workspace: `groundwork-azure`

### Pulumi State

Pulumi can use:
- **Pulumi Cloud** (recommended): Automatic encryption, history, RBAC
- **Local**: File-based state in `~/.pulumi/`
- **Self-hosted**: S3, Azure Blob, etc.

To use Pulumi Cloud:
```bash
pulumi login
```

To use local state:
```bash
pulumi login --local
```

## Outputs Comparison

### Terraform Outputs

```bash
cd ../../azure
terraform output k3s_vm_public_ip
terraform output postgresql_server_fqdn
```

### Pulumi Outputs

```bash
cd ../pulumi/azure
pulumi stack output k3sVmPublicIp
pulumi stack output postgresqlServerFqdn
```

## CI/CD Updates

Update your CI/CD pipelines to use Pulumi:

### GitHub Actions Example

```yaml
- name: Install Pulumi
  uses: pulumi/actions@v4

- name: Deploy Infrastructure
  run: |
    cd pulumi/azure
    npm install
    pulumi up --yes
  env:
    PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
```

## Rollback Plan

If you need to rollback to Terraform:

1. **Export Pulumi State**
   ```bash
   pulumi stack export > pulumi-state-backup.json
   ```

2. **Destroy Pulumi Resources** (if needed)
   ```bash
   pulumi destroy
   ```

3. **Re-import to Terraform**
   ```bash
   cd ../../azure
   terraform import azurerm_resource_group.ameciclo /subscriptions/{sub-id}/resourceGroups/ameciclo-rg
   # ... continue for all resources
   ```

## Support

For questions or issues during migration:
- [Pulumi Migration Guide](https://www.pulumi.com/docs/guides/adopting/)
- [Pulumi Slack Community](https://slack.pulumi.com/)

