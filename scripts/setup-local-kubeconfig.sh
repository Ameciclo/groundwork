#!/bin/bash
set -e

# Setup Local Kubeconfig for K3s Cluster Access
# This script copies the kubeconfig from the K3s VM and configures it for local access via Tailscale

echo "=========================================="
echo "K3s Local Kubeconfig Setup"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "infrastructure/pulumi/Pulumi.yaml" ]; then
    echo "Error: Must run from repository root"
    exit 1
fi

# Get K3s VM IP from Pulumi
echo "Getting K3s VM IP from Pulumi..."
cd infrastructure/pulumi
K3S_IP=$(pulumi stack output k3sPublicIp 2>/dev/null)

if [ -z "$K3S_IP" ]; then
    echo "Error: Could not get K3s IP from Pulumi"
    echo "Make sure infrastructure is deployed: pulumi up"
    exit 1
fi

echo "K3s VM IP: $K3S_IP"
cd ../..

# Create .kube directory if it doesn't exist
mkdir -p ~/.kube

# Backup existing k3s-config if it exists
if [ -f ~/.kube/k3s-config ]; then
    echo "Backing up existing k3s-config..."
    cp ~/.kube/k3s-config ~/.kube/k3s-config.backup.$(date +%Y%m%d-%H%M%S)
fi

# Copy kubeconfig from K3s VM
echo "Copying kubeconfig from K3s VM..."
scp -o StrictHostKeyChecking=no azureuser@$K3S_IP:~/.kube/config ~/.kube/k3s-config

# Update server URL to use private IP (accessible via Tailscale)
echo "Updating server URL to use Tailscale..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's|https://127.0.0.1:6443|https://10.10.1.4:6443|g' ~/.kube/k3s-config
else
    # Linux
    sed -i 's|https://127.0.0.1:6443|https://10.10.1.4:6443|g' ~/.kube/k3s-config
fi

echo ""
echo "✅ Kubeconfig setup complete!"
echo ""
echo "Kubeconfig saved to: ~/.kube/k3s-config"
echo ""
echo "Next steps:"
echo ""
echo "1. Accept Tailscale routes (if not already done):"
echo "   sudo tailscale up --accept-routes"
echo ""
echo "2. Test kubectl access:"
echo "   export KUBECONFIG=~/.kube/k3s-config"
echo "   kubectl get nodes"
echo ""
echo "3. Launch k9s:"
echo "   k9s --kubeconfig ~/.kube/k3s-config"
echo ""
echo "Or add to your shell profile (~/.zshrc or ~/.bashrc):"
echo "   alias k9s-k3s='KUBECONFIG=~/.kube/k3s-config k9s'"
echo "   alias kubectl-k3s='KUBECONFIG=~/.kube/k3s-config kubectl'"
echo ""

