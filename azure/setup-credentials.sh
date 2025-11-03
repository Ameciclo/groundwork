#!/bin/bash
# Setup Azure Credentials for Terraform
# This script will guide you through getting all required credentials

set -e

echo "=========================================="
echo "Azure Credentials Setup for Terraform"
echo "=========================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed"
    echo "Install it with: brew install azure-cli (macOS) or curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash (Linux)"
    exit 1
fi

echo "✅ Azure CLI found"
echo ""

# Step 1: Login
echo "Step 1: Logging into Azure..."
az login

echo ""
echo "Step 2: Getting subscription ID..."
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "✅ Subscription ID: $SUBSCRIPTION_ID"

echo ""
echo "Step 3: Creating service principal..."
echo "This will create a service principal named 'ameciclo-terraform'"
echo ""

SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "ameciclo-terraform" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID)

CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.password')
TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenant')

echo "✅ Service Principal created"
echo ""

# Step 4: Get SSH key
echo "Step 4: Getting SSH public key..."
if [ -f ~/.ssh/id_rsa.pub ]; then
    SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
    echo "✅ SSH key found"
else
    echo "⚠️  SSH key not found at ~/.ssh/id_rsa.pub"
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
    echo "✅ SSH key generated"
fi

echo ""
echo "Step 5: Generating PostgreSQL password..."
POSTGRES_PASSWORD=$(openssl rand -base64 32)
echo "✅ PostgreSQL password generated"

echo ""
echo "=========================================="
echo "✅ All credentials obtained!"
echo "=========================================="
echo ""
echo "Now you have two options:"
echo ""
echo "OPTION 1: Set as environment variables (for local Terraform)"
echo "=========================================="
echo "Copy and paste these commands:"
echo ""
echo "export TF_VAR_azure_subscription_id=\"$SUBSCRIPTION_ID\""
echo "export TF_VAR_azure_client_id=\"$CLIENT_ID\""
echo "export TF_VAR_azure_client_secret=\"$CLIENT_SECRET\""
echo "export TF_VAR_azure_tenant_id=\"$TENANT_ID\""
echo "export TF_VAR_postgresql_admin_password=\"$POSTGRES_PASSWORD\""
echo "export TF_VAR_admin_ssh_public_key=\"$SSH_KEY\""
echo ""
echo "Then run: cd azure && terraform apply"
echo ""
echo ""
echo "OPTION 2: Add to HCP Terraform (recommended)"
echo "=========================================="
echo "Go to: https://app.terraform.io/app/Ameciclo/groundwork-azure/variables"
echo ""
echo "Add these as Environment Variables (mark as sensitive):"
echo ""
echo "TF_VAR_azure_subscription_id = $SUBSCRIPTION_ID"
echo "TF_VAR_azure_client_id = $CLIENT_ID"
echo "TF_VAR_azure_client_secret = $CLIENT_SECRET"
echo "TF_VAR_azure_tenant_id = $TENANT_ID"
echo "TF_VAR_postgresql_admin_password = $POSTGRES_PASSWORD"
echo "TF_VAR_admin_ssh_public_key = $SSH_KEY"
echo ""
echo "Then run: cd azure && terraform apply"
echo ""
echo "=========================================="
echo "⚠️  SECURITY NOTES:"
echo "=========================================="
echo "- Never commit credentials to Git"
echo "- Never share your client_secret"
echo "- Use HCP Terraform for team collaboration"
echo "- Rotate credentials regularly"
echo ""

