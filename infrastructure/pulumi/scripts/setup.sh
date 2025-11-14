#!/bin/bash

# Ameciclo Infrastructure Setup Script
# This script helps set up the Pulumi environment for Azure deployment

set -e

echo "🚀 Ameciclo Infrastructure Setup"
echo "================================"

# Check if Pulumi is installed
if ! command -v pulumi &> /dev/null; then
    echo "❌ Pulumi CLI not found. Please install it first:"
    echo "   https://www.pulumi.com/docs/get-started/install/"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+ first:"
    echo "   https://nodejs.org/"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the pulumi/infrastructure directory"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Setup Pulumi Cloud
echo ""
echo "🌩️  Pulumi Cloud Setup"
echo "====================="

# Check if already logged in
if ! pulumi whoami &> /dev/null; then
    echo "🔐 Logging into Pulumi Cloud..."
    echo "This will open your browser to create/login to your Pulumi account"
    read -p "Press Enter to continue..."
    pulumi login
else
    echo "✅ Already logged into Pulumi Cloud as: $(pulumi whoami)"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Initialize Pulumi stack if it doesn't exist
if ! pulumi stack ls | grep -q "prod"; then
    echo "🏗️  Creating Pulumi stack..."
    pulumi stack init prod
else
    echo "✅ Pulumi stack 'prod' already exists"
fi

# Select the prod stack
pulumi stack select prod

echo ""
echo "🔧 Configuration Setup"
echo "======================"
echo ""

# Check if Azure CLI is available and logged in
AZURE_CLI_AVAILABLE=false
if command -v az &> /dev/null; then
    if az account show &> /dev/null 2>&1; then
        AZURE_CLI_AVAILABLE=true
        echo "✅ Azure CLI detected and logged in"

        # Auto-detect Azure credentials
        DETECTED_SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null)
        DETECTED_TENANT_ID=$(az account show --query tenantId -o tsv 2>/dev/null)
        SUBSCRIPTION_NAME=$(az account show --query name -o tsv 2>/dev/null)

        echo "📋 Detected Azure Account:"
        echo "   Subscription: $SUBSCRIPTION_NAME"
        echo "   Subscription ID: $DETECTED_SUBSCRIPTION_ID"
        echo "   Tenant ID: $DETECTED_TENANT_ID"
        echo ""
    else
        echo "⚠️  Azure CLI found but not logged in"
        echo "   Run 'az login' to auto-detect credentials"
        echo ""
    fi
else
    echo "⚠️  Azure CLI not found - you'll need to enter credentials manually"
    echo "   Install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    echo ""
fi

echo "Please provide the following configuration values:"
echo ""

# Function to set config if not already set
set_config_if_empty() {
    local key=$1
    local prompt=$2
    local secret_flag=$3
    local default_value=$4

    if ! pulumi config get "$key" &> /dev/null; then
        if [ -n "$default_value" ]; then
            echo -n "$prompt [$default_value]: "
        else
            echo -n "$prompt: "
        fi

        if [ "$secret_flag" = "--secret" ]; then
            read -s value
            echo ""
        else
            read value
        fi

        # Use default if no value provided
        if [ -z "$value" ] && [ -n "$default_value" ]; then
            value="$default_value"
            echo "   Using detected value"
        fi

        pulumi config set "$key" "$value" $secret_flag
    else
        echo "✅ $key already configured"
    fi
}

# Azure configuration with auto-detection
if [ "$AZURE_CLI_AVAILABLE" = true ]; then
    set_config_if_empty "azure-native:subscriptionId" "Azure Subscription ID" "--secret" "$DETECTED_SUBSCRIPTION_ID"
    set_config_if_empty "azure-native:tenantId" "Azure Tenant ID" "--secret" "$DETECTED_TENANT_ID"
else
    set_config_if_empty "azure-native:subscriptionId" "Azure Subscription ID" "--secret"
    set_config_if_empty "azure-native:tenantId" "Azure Tenant ID" "--secret"
fi

# Service Principal credentials (cannot be auto-detected)
echo ""
echo "🔑 Service Principal Credentials"
echo "   You need to create a Service Principal for Pulumi."
echo "   Run: az ad sp create-for-rbac --name pulumi-ameciclo --role Contributor"
echo "   Or use the helper script: ./scripts/get-azure-credentials.sh"
echo ""
set_config_if_empty "azure-native:clientId" "Azure Client ID (Service Principal)" "--secret"
set_config_if_empty "azure-native:clientSecret" "Azure Client Secret" "--secret"

# PostgreSQL configuration
set_config_if_empty "postgresqlAdminUsername" "PostgreSQL Admin Username" "--secret"
set_config_if_empty "postgresqlAdminPassword" "PostgreSQL Admin Password" "--secret"

# SSH Key configuration
if ! pulumi config get "adminSshPublicKey" &> /dev/null; then
    if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        echo "🔑 Using SSH public key from ~/.ssh/id_rsa.pub"
        pulumi config set "adminSshPublicKey" "$(cat ~/.ssh/id_rsa.pub)" --secret
    else
        echo "❌ SSH public key not found at ~/.ssh/id_rsa.pub"
        echo "   Please generate one with: ssh-keygen -t rsa -b 4096"
        exit 1
    fi
else
    echo "✅ adminSshPublicKey already configured"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review configuration: pulumi config"
echo "2. 🧪 DRY RUN (Preview): pulumi preview"
echo "3. 🚀 Deploy infrastructure: pulumi up"
echo ""
echo "💡 Useful commands:"
echo "   pulumi preview --diff              # Show detailed changes"
echo "   pulumi preview --save-plan plan.json  # Save preview to file"
echo "   pulumi stack output               # View current outputs"
echo "   pulumi destroy                    # Delete all resources"
echo ""
