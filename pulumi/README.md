# Pulumi Infrastructure as Code

This directory contains Pulumi infrastructure as code configurations for Ameciclo's cloud infrastructure.

## Directory Structure

```
pulumi/
└── azure/          # Azure infrastructure with K3s (TypeScript)
    ├── index.ts    # Main infrastructure code
    ├── Pulumi.yaml # Project configuration
    ├── package.json
    ├── tsconfig.json
    ├── Makefile
    ├── README.md
    ├── MIGRATION.md
    └── Pulumi.prod.yaml.example
```

## Why Pulumi?

Pulumi offers several advantages over traditional Infrastructure as Code tools:

### 1. **Use Real Programming Languages**
- Write infrastructure in TypeScript, Python, Go, or C#
- Full IDE support with IntelliSense and type checking
- Leverage existing language features (loops, conditionals, functions)

### 2. **Type Safety**
- Catch errors at compile time, not runtime
- Auto-completion for resource properties
- Inline documentation in your IDE

### 3. **Better Testing**
- Write unit tests in the same language
- Integration testing with real cloud resources
- Policy as code with CrossGuard

### 4. **Secrets Management**
- Built-in encryption for sensitive values
- No need for external secret management tools
- Secrets are encrypted in state files

### 5. **Multi-Cloud Support**
- Same language across AWS, Azure, GCP, Kubernetes
- Consistent patterns and practices
- Easy to mix and match providers

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v18+ (for TypeScript projects)
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/)
- Cloud provider CLI (Azure CLI, AWS CLI, etc.)

### Installation

```bash
# Install Pulumi CLI
curl -fsSL https://get.pulumi.com | sh

# Or using Homebrew
brew install pulumi
```

### Quick Start

```bash
# Navigate to the infrastructure directory
cd pulumi/azure

# Install dependencies
npm install

# Login to Pulumi
pulumi login

# Create or select a stack
pulumi stack init prod

# Configure the stack
pulumi config set --secret groundwork-azure:postgresql_admin_password <password>
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"

# Preview changes
pulumi preview

# Deploy infrastructure
pulumi up
```

## Available Configurations

### Azure Infrastructure (`azure/`)

Provisions Azure resources including:
- Resource Group
- Virtual Network with subnets
- Network Security Groups
- K3s Virtual Machine (Ubuntu 22.04 LTS)
- PostgreSQL Flexible Server
- Private DNS Zone

**Documentation**: See [azure/README.md](azure/README.md)

**Migration Guide**: See [azure/MIGRATION.md](azure/MIGRATION.md)

## Comparison: Terraform vs Pulumi

| Feature | Terraform | Pulumi |
|---------|-----------|--------|
| Language | HCL | TypeScript, Python, Go, C#, Java |
| Type Safety | Limited | Full (with TypeScript) |
| IDE Support | Basic | Excellent (IntelliSense, etc.) |
| Testing | External tools | Native language testing |
| Secrets | External (Vault, etc.) | Built-in encryption |
| State Management | Terraform Cloud/S3 | Pulumi Cloud/S3/Azure Blob |
| Learning Curve | New DSL | Use existing language skills |

## State Management

Pulumi supports multiple state backends:

### Pulumi Cloud (Recommended)
- Automatic encryption
- Team collaboration
- Audit logs and history
- RBAC and policies

```bash
pulumi login
```

### Self-Hosted
- Azure Blob Storage
- AWS S3
- Google Cloud Storage
- Local filesystem

```bash
pulumi login azblob://<container-path>
pulumi login s3://<bucket-name>
pulumi login --local
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: pulumi/actions@v4
        with:
          command: up
          stack-name: prod
          work-dir: pulumi/azure
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
```

## Best Practices

1. **Use Stacks for Environments**
   - `dev`, `staging`, `prod` stacks
   - Separate configuration per stack
   - Isolated state management

2. **Encrypt Secrets**
   ```bash
   pulumi config set --secret <key> <value>
   ```

3. **Use Configuration Files**
   - Store non-secret config in `Pulumi.<stack>.yaml`
   - Version control example files
   - Document required secrets

4. **Export Stack State**
   ```bash
   pulumi stack export > backup.json
   ```

5. **Use Resource Options**
   - `dependsOn` for explicit dependencies
   - `protect` for critical resources
   - `ignoreChanges` for external modifications

## Resources

- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [Azure Native Provider](https://www.pulumi.com/registry/packages/azure-native/)
- [Pulumi Examples](https://github.com/pulumi/examples)
- [Pulumi Community Slack](https://slack.pulumi.com/)

## Support

For questions or issues:
1. Check the specific infrastructure README (e.g., `azure/README.md`)
2. Review the migration guide if coming from Terraform
3. Consult Pulumi documentation
4. Ask in Pulumi Community Slack

