# PR: Migrate Azure and K3s Infrastructure to Pulumi

## Summary

This PR introduces Pulumi infrastructure as code (TypeScript) as an alternative to the existing Terraform configuration for Azure and K3s infrastructure. The Pulumi implementation provides the same infrastructure with improved type safety, better IDE support, and native secrets management.

## What's Changed

### Added
- ✨ **New Pulumi Azure Infrastructure** (`pulumi/azure/`)
  - Complete TypeScript implementation of Azure + K3s infrastructure
  - Equivalent to existing `azure/` Terraform configuration
  - All resources migrated: Resource Group, VNet, NSGs, K3s VM, PostgreSQL

- 📚 **Comprehensive Documentation**
  - `pulumi/README.md` - Overview of Pulumi setup
  - `pulumi/azure/README.md` - Azure-specific documentation
  - `pulumi/azure/MIGRATION.md` - Migration guide from Terraform
  - Configuration examples and best practices

- 🛠️ **Developer Tools**
  - `pulumi/azure/Makefile` - Convenient commands for common tasks
  - `pulumi/azure/.gitignore` - Pulumi-specific ignore rules
  - TypeScript configuration with strict type checking

### Modified
- 📝 Updated root `.gitignore` to include Pulumi-specific patterns

## Infrastructure Parity

The Pulumi configuration provides 100% feature parity with the Terraform configuration:

| Resource | Terraform | Pulumi | Status |
|----------|-----------|--------|--------|
| Resource Group | ✅ | ✅ | ✅ Migrated |
| Virtual Network | ✅ | ✅ | ✅ Migrated |
| K3s Subnet | ✅ | ✅ | ✅ Migrated |
| Database Subnet | ✅ | ✅ | ✅ Migrated |
| K3s NSG + Rules | ✅ | ✅ | ✅ Migrated |
| Database NSG + Rules | ✅ | ✅ | ✅ Migrated |
| K3s VM (Ubuntu 22.04) | ✅ | ✅ | ✅ Migrated |
| Public IP | ✅ | ✅ | ✅ Migrated |
| Network Interface | ✅ | ✅ | ✅ Migrated |
| PostgreSQL Flexible Server | ✅ | ✅ | ✅ Migrated |
| PostgreSQL Databases (atlas, kong) | ✅ | ✅ | ✅ Migrated |
| Private DNS Zone | ✅ | ✅ | ✅ Migrated |
| DNS Zone VNet Link | ✅ | ✅ | ✅ Migrated |
| Storage Account | ⚠️ Disabled | ⚠️ Disabled | ✅ Migrated (commented) |

## Benefits of Pulumi

### 1. Type Safety
- Full TypeScript type checking at compile time
- Catch configuration errors before deployment
- Auto-completion for all resource properties

### 2. Better Developer Experience
- Use familiar programming language (TypeScript)
- Full IDE support with IntelliSense
- Inline documentation and examples

### 3. Built-in Secrets Management
- Encrypted secrets in state files
- No need for external secret management
- Simple CLI: `pulumi config set --secret <key> <value>`

### 4. Improved Testing
- Write unit tests in TypeScript
- Integration testing with real resources
- Policy as code with CrossGuard

### 5. Better State Management
- Pulumi Cloud with automatic encryption
- Team collaboration features
- Audit logs and history

## Configuration

### Region Update
- Updated default region from `eastus2` to `westus3` (as per current usage)

### Required Secrets
```bash
pulumi config set --secret groundwork-azure:postgresql_admin_password <password>
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
```

### Optional Configuration
All other values have sensible defaults matching the Terraform configuration. See `Pulumi.prod.yaml.example` for full configuration options.

## Migration Path

Three migration strategies are documented in `pulumi/azure/MIGRATION.md`:

1. **Blue-Green Deployment** (Recommended)
   - Deploy new infrastructure alongside existing
   - Migrate workloads gradually
   - Zero downtime

2. **Import Existing Resources**
   - Import Terraform-managed resources into Pulumi
   - Gradual transition
   - No infrastructure recreation

3. **Fresh Deployment**
   - Backup data
   - Destroy and recreate
   - Fastest but requires downtime

## Testing

### Local Testing
```bash
cd pulumi/azure
npm install
npm run build
pulumi preview
```

### Deployment
```bash
pulumi up
```

## Backwards Compatibility

- ✅ Existing Terraform configuration remains unchanged
- ✅ No impact on current infrastructure
- ✅ Can run Terraform and Pulumi side-by-side
- ✅ Migration can be done gradually

## Documentation

All documentation is included:
- Quick start guide
- Configuration reference
- Migration strategies
- Troubleshooting tips
- Cost estimation
- CI/CD examples

## Next Steps

After this PR is merged:

1. **Review Documentation**
   - Read `pulumi/README.md` for overview
   - Review `pulumi/azure/README.md` for Azure-specific details

2. **Test Deployment** (Optional)
   - Deploy to a test stack
   - Verify all resources are created correctly
   - Test connectivity and functionality

3. **Plan Migration** (When Ready)
   - Choose migration strategy
   - Schedule migration window
   - Follow migration guide

4. **No Immediate Action Required**
   - Existing Terraform infrastructure continues to work
   - Pulumi is available when you're ready to migrate

## Files Changed

```
.gitignore                                  # Added Pulumi patterns
pulumi/README.md                            # New: Pulumi overview
pulumi/PR_DESCRIPTION.md                    # New: This file
pulumi/azure/.gitignore                     # New: Pulumi-specific ignores
pulumi/azure/MIGRATION.md                   # New: Migration guide
pulumi/azure/Makefile                       # New: Convenience commands
pulumi/azure/Pulumi.prod.yaml.example       # New: Config example
pulumi/azure/Pulumi.yaml                    # New: Project config
pulumi/azure/README.md                      # New: Azure docs
pulumi/azure/index.ts                       # New: Infrastructure code
pulumi/azure/package.json                   # New: Node dependencies
pulumi/azure/tsconfig.json                  # New: TypeScript config
```

## Checklist

- [x] All Terraform resources migrated to Pulumi
- [x] Documentation complete
- [x] Configuration examples provided
- [x] Migration guide written
- [x] .gitignore updated
- [x] Makefile for convenience
- [x] Type safety enabled
- [x] Secrets management documented
- [x] No breaking changes to existing infrastructure

## Questions?

See the documentation in `pulumi/azure/README.md` or the migration guide in `pulumi/azure/MIGRATION.md`.

