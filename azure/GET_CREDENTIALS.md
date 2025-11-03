# Getting Azure Credentials for Terraform

This guide will help you get all the credentials needed to run Terraform on Azure.

## Prerequisites

1. **Azure CLI installed**
   ```bash
   # macOS
   brew install azure-cli
   
   # Ubuntu/Debian
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Verify installation
   az --version
   ```

2. **Azure Account** - You need an active Azure subscription

## Step 1: Login to Azure

```bash
az login
```

This will open your browser to authenticate. After logging in, you'll see your subscriptions.

## Step 2: Get Your Subscription ID

```bash
# List all subscriptions
az account list --output table

# Get just the subscription ID (copy this)
az account show --query id --output tsv
```

**Save this value as:** `azure_subscription_id`

## Step 3: Create a Service Principal

A service principal is like a "service account" for Terraform to use. Run this command:

```bash
# Create service principal with Contributor role on your subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az ad sp create-for-rbac \
  --name "ameciclo-terraform" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID
```

**Output will look like:**
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "ameciclo-terraform",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**Save these values:**
- `appId` → `azure_client_id`
- `password` → `azure_client_secret`
- `tenant` → `azure_tenant_id`

## Step 4: Get SSH Public Key

You need an SSH key for the VM. If you don't have one:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Get your public key
cat ~/.ssh/id_rsa.pub
```

**Save this value as:** `admin_ssh_public_key`

## Step 5: Create PostgreSQL Admin Password

Choose a strong password for PostgreSQL:

```bash
# Generate a random password
openssl rand -base64 32
```

**Save this value as:** `postgresql_admin_password`

## Step 6: Set Environment Variables

Now set all these as environment variables for Terraform:

```bash
export TF_VAR_azure_subscription_id="your-subscription-id"
export TF_VAR_azure_client_id="your-app-id"
export TF_VAR_azure_client_secret="your-password"
export TF_VAR_azure_tenant_id="your-tenant-id"
export TF_VAR_postgresql_admin_password="your-postgres-password"
export TF_VAR_admin_ssh_public_key="your-ssh-public-key"
```

## Step 7: Verify Credentials

Test that everything works:

```bash
cd azure
terraform plan
```

If you see the plan without errors, you're good to go!

## Step 8: Run Terraform

Now you can apply:

```bash
cd azure
terraform apply
```

## Step 9: (Optional) Add to HCP Terraform

If you want to use HCP Terraform (recommended for team collaboration):

1. Go to: https://app.terraform.io/app/Ameciclo/groundwork-azure/variables

2. Click "Add variable" and add these as **Environment Variables** (mark as sensitive):
   - `TF_VAR_azure_subscription_id`
   - `TF_VAR_azure_client_id`
   - `TF_VAR_azure_client_secret`
   - `TF_VAR_azure_tenant_id`
   - `TF_VAR_postgresql_admin_password`
   - `TF_VAR_admin_ssh_public_key`

3. Then you can run `terraform apply` from HCP Terraform UI

## Quick Reference

| Variable | Where to Get It |
|----------|-----------------|
| `azure_subscription_id` | `az account show --query id --output tsv` |
| `azure_client_id` | From service principal output (`appId`) |
| `azure_client_secret` | From service principal output (`password`) |
| `azure_tenant_id` | From service principal output (`tenant`) |
| `postgresql_admin_password` | Generate with `openssl rand -base64 32` |
| `admin_ssh_public_key` | `cat ~/.ssh/id_rsa.pub` |

## Troubleshooting

### "Insufficient privileges to complete the operation"
- You need to be an Azure subscription owner or have the right permissions
- Contact your Azure admin

### "Service principal not found"
- Wait a few seconds and try again
- Service principals take a moment to propagate

### "Invalid SSH key format"
- Make sure you're using the **public** key (from `~/.ssh/id_rsa.pub`)
- Not the private key!

## Security Notes

⚠️ **IMPORTANT:**
- Never commit credentials to Git
- Never share your `azure_client_secret`
- Use environment variables or HCP Terraform for storing secrets
- Rotate credentials regularly
- Use the principle of least privilege (don't give more permissions than needed)

## Next Steps

Once you have all credentials set:

1. Run `terraform plan` to see what will be created
2. Run `terraform apply` to create resources
3. Use the Ansible playbook to install K3s: `ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml`

