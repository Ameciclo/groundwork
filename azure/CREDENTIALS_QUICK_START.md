# Quick Start: Get Azure Credentials

## Fastest Way (Automated Script)

```bash
cd azure
bash setup-credentials.sh
```

This script will:
1. ✅ Log you into Azure
2. ✅ Get your subscription ID
3. ✅ Create a service principal
4. ✅ Get your SSH key
5. ✅ Generate a PostgreSQL password
6. ✅ Show you the credentials in both formats

## Manual Way (Step by Step)

### 1. Install Azure CLI

```bash
# macOS
brew install azure-cli

# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Login to Azure

```bash
az login
```

### 3. Get Subscription ID

```bash
az account show --query id --output tsv
```

**Copy this value** → `azure_subscription_id`

### 4. Create Service Principal

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az ad sp create-for-rbac \
  --name "ameciclo-terraform" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID
```

**From the output, copy:**
- `appId` → `azure_client_id`
- `password` → `azure_client_secret`
- `tenant` → `azure_tenant_id`

### 5. Get SSH Public Key

```bash
# If you don't have one, generate it:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Get the public key:
cat ~/.ssh/id_rsa.pub
```

**Copy this value** → `admin_ssh_public_key`

### 6. Generate PostgreSQL Password

```bash
openssl rand -base64 32
```

**Copy this value** → `postgresql_admin_password`

## Now You Have Two Options

### Option A: Use Environment Variables (Local)

```bash
export TF_VAR_azure_subscription_id="your-subscription-id"
export TF_VAR_azure_client_id="your-app-id"
export TF_VAR_azure_client_secret="your-password"
export TF_VAR_azure_tenant_id="your-tenant-id"
export TF_VAR_postgresql_admin_password="your-postgres-password"
export TF_VAR_admin_ssh_public_key="your-ssh-public-key"

# Then run:
cd azure
terraform apply
```

### Option B: Use HCP Terraform (Recommended)

1. Go to: https://app.terraform.io/app/Ameciclo/groundwork-azure/variables

2. Click "Add variable" for each:
   - `TF_VAR_azure_subscription_id`
   - `TF_VAR_azure_client_id`
   - `TF_VAR_azure_client_secret` (mark as sensitive)
   - `TF_VAR_azure_tenant_id`
   - `TF_VAR_postgresql_admin_password` (mark as sensitive)
   - `TF_VAR_admin_ssh_public_key`

3. Then run:
   ```bash
   cd azure
   terraform apply
   ```

## Verify It Works

```bash
cd azure
terraform plan
```

If you see the plan without errors, you're ready!

## Next Steps

1. Run `terraform apply` to create resources
2. Wait for resources to be created (5-10 minutes)
3. Get the VM public IP: `terraform output vm_public_ip`
4. Run Ansible to install K3s:
   ```bash
   ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml
   ```

## Troubleshooting

**"Insufficient privileges"**
- You need to be an Azure subscription owner

**"Service principal not found"**
- Wait a few seconds and try again

**"Invalid SSH key"**
- Make sure you're using the PUBLIC key (from `~/.ssh/id_rsa.pub`)

## For More Details

See `azure/GET_CREDENTIALS.md` for the full guide with security notes and troubleshooting.

