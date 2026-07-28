#!/bin/bash

# Ameciclo Infrastructure Setup Script
# Sets up a local environment to run Pulumi against the self-managed
# Azure Blob state backend. See README.md's "Initial setup" and "Access"
# sections for the full picture.

set -e

STORAGE_ACCOUNT="ameciclostorprod"
BACKEND_URL="azblob://pulumi-state?storage_account=${STORAGE_ACCOUNT}"
REQUIRED_GROUP="TI Ameciclo"
EXPECTED_TENANT_DOMAIN="ameciclo.onmicrosoft.com"

echo "🚀 Ameciclo Infrastructure Setup"
echo "================================"

# --- Prerequisites ----------------------------------------------------------

if ! command -v pulumi &> /dev/null; then
    echo "❌ Pulumi CLI not found. Install it first:"
    echo "   https://www.pulumi.com/docs/get-started/install/"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install Node.js 18+ first:"
    echo "   https://nodejs.org/"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

if [ ! -f "package.json" ]; then
    echo "❌ Run this script from infrastructure/pulumi/"
    exit 1
fi

echo "✅ Prerequisites installed"

# --- Azure login --------------------------------------------------------

echo ""
echo "🔑 Azure login"
echo "=============="

if ! az account show &> /dev/null; then
    echo "Not logged in to Azure CLI — running 'az login'..."
    az login --only-show-errors > /dev/null
fi

TENANT_DOMAIN=$(az account show --query tenantDefaultDomain -o tsv 2>/dev/null)
if [ "$TENANT_DOMAIN" != "$EXPECTED_TENANT_DOMAIN" ]; then
    echo "⚠️  Logged in to tenant '$TENANT_DOMAIN', expected '$EXPECTED_TENANT_DOMAIN'."
    echo "   Run: az login --tenant $EXPECTED_TENANT_DOMAIN"
fi
echo "✅ Azure CLI logged in as $(az account show --query user.name -o tsv)"

# Best-effort check for TI Ameciclo membership. Not required for `pulumi up`
# itself (that only needs Contributor + Storage Blob Data Contributor), but
# is required for `az ssh vm` / AAD Postgres login — see README.md#access.
MY_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)
if [ -n "$MY_OBJECT_ID" ]; then
    GROUP_ID=$(az ad group show --group "$REQUIRED_GROUP" --query id -o tsv 2>/dev/null || true)
    if [ -n "$GROUP_ID" ]; then
        IS_MEMBER=$(az ad group member check --group "$GROUP_ID" --member-id "$MY_OBJECT_ID" --query value -o tsv 2>/dev/null || echo "false")
        if [ "$IS_MEMBER" != "true" ]; then
            echo "⚠️  You're not a member of the '$REQUIRED_GROUP' Entra ID group."
            echo "   Ask an admin to add you — needed for 'az ssh vm' and AAD Postgres login."
        fi
    fi
fi

# --- Pulumi state backend -------------------------------------------------

echo ""
echo "☁️  Pulumi state backend"
echo "========================"

if ! pulumi whoami -v 2>/dev/null | grep -q "$STORAGE_ACCOUNT"; then
    echo "Logging in to the self-managed state backend..."
    pulumi login "$BACKEND_URL"
else
    echo "✅ Already logged in to the state backend"
fi

if [ -z "$PULUMI_CONFIG_PASSPHRASE" ]; then
    echo ""
    echo "🔒 This stack's secrets are encrypted with a shared passphrase (not a Pulumi Cloud account)."
    read -r -s -p "Enter it now (ask an existing admin if you don't have it): " PULUMI_CONFIG_PASSPHRASE
    echo ""
    export PULUMI_CONFIG_PASSPHRASE
    echo "   (set for this script only — add 'export PULUMI_CONFIG_PASSPHRASE=...' to your shell profile to persist it)"
fi

# --- Dependencies and stack -------------------------------------------------

echo ""
echo "📦 Installing dependencies..."
npm install

# The 'prod' stack already exists on the self-managed backend — select it,
# never `pulumi stack init` a new one.
pulumi stack select prod

echo ""
echo "🧪 Verifying access (pulumi preview)..."
pulumi preview

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "   pulumi preview --diff   # see what would change, in detail"
echo "   pulumi up               # deploy"
echo "   pulumi stack output     # view outputs (IPs, FQDNs, etc.)"
echo ""
echo "For SSH / Postgres access via Azure AD, see README.md's 'Access' section."
