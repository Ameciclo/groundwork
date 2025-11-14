# Pulumi ESC Environment Setup

This directory contains Pulumi ESC (Environments, Secrets, and Configuration) environment definitions.

## What is Pulumi ESC?

Pulumi ESC is a centralized secrets and configuration management service that:

- ✅ **Centralizes secrets** - Store all credentials in one secure location
- ✅ **Eliminates hardcoded secrets** - No more secrets in config files
- ✅ **Supports multiple environments** - dev, staging, prod, etc.
- ✅ **Integrates with Pulumi IaC** - Seamless configuration injection
- ✅ **Provides dynamic credentials** - Generate short-lived cloud credentials
- ✅ **Tracks changes** - Version control for secrets

## Setup Instructions

### 1. Login to Pulumi Cloud

```bash
pulumi login
```

### 2. Create the Production Environment

```bash
# Create the environment (replace <your-org> with your Pulumi organization)
pulumi env init <your-org>/infrastructure-prod

# Edit the environment
pulumi env edit <your-org>/infrastructure-prod
```

### 3. Copy Environment Definition

Copy the contents of `prod.yaml` into the Pulumi Cloud environment editor.

### 4. Update Placeholder Values

Replace the following placeholder values with your actual secrets:

#### SSH Public Key

Get your SSH public key:
```bash
cat ~/.ssh/id_rsa.pub
```

Update in the environment:
```yaml
values:
  ssh:
    publicKey:
      fn::secret: "ssh-rsa AAAAB3NzaC1yc2E... your-email@example.com"
```

### 5. Save the Environment

Click "Save" in the Pulumi Cloud UI.

### 6. Verify the Environment

```bash
# View the environment
pulumi env open <your-org>/infrastructure-prod

# Test that values are accessible
pulumi env get <your-org>/infrastructure-prod
```

## Using the Environment

The environment is automatically imported by the Pulumi stack via `Pulumi.prod.yaml`:

```yaml
environment:
  - infrastructure-prod
```

Values are accessible in your Pulumi program using the standard config API:

```typescript
const config = new pulumi.Config();
const sshPublicKey = config.requireSecret("adminSshPublicKey");
```

## Environment Structure

```yaml
values:
  # Define your secrets and configuration here
  ssh:
    publicKey:
      fn::secret: "your-ssh-public-key"

  azure:
    location: "westus3"
    projectName: "ameciclo"

  # pulumiConfig must be inside values block
  pulumiConfig:
    # Expose values to Pulumi IaC stacks
    adminSshPublicKey: ${ssh.publicKey}
    location: ${azure.location}
    projectName: ${azure.projectName}
```

## Security Best Practices

1. **Never commit secrets to Git** - ESC environments are stored in Pulumi Cloud, not in your repository
2. **Use `fn::secret`** - Mark sensitive values as secrets
3. **Limit access** - Use RBAC to control who can view/edit environments
4. **Audit changes** - Review audit logs for environment modifications
5. **Rotate secrets regularly** - Update credentials periodically

## Additional Resources

- [Pulumi ESC Documentation](https://www.pulumi.com/docs/esc/)
- [ESC CLI Reference](https://www.pulumi.com/docs/esc/cli/)
- [Pulumi IaC Integration](https://www.pulumi.com/docs/esc/integrations/infrastructure/pulumi-iac/)

