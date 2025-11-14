#!/bin/bash
set -e

# Update Ansible Inventory from Pulumi Outputs
# This script automatically updates the inventory.yml file with the K3s VM IP from Pulumi

echo "=========================================="
echo "Updating Ansible Inventory from Pulumi"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "../../infrastructure/pulumi/Pulumi.yaml" ]; then
    echo "Error: Must run from automation/ansible directory"
    exit 1
fi

# Get Pulumi outputs
cd ../../infrastructure/pulumi

echo "Getting K3s VM IP from Pulumi..."
K3S_IP=$(pulumi stack output k3sPublicIp 2>/dev/null)

if [ -z "$K3S_IP" ]; then
    echo "Error: Could not get K3s IP from Pulumi"
    echo "Make sure infrastructure is deployed: pulumi up"
    exit 1
fi

echo "K3s VM IP: $K3S_IP"
echo ""

# Update inventory file
cd ../../automation/ansible

echo "Updating inventory.yml..."
cat > inventory.yml <<EOF
---
# Ansible Inventory for K3s VM
# Auto-generated from Pulumi outputs on $(date)

all:
  hosts:
    k3s-vm:
      ansible_host: $K3S_IP
      ansible_user: azureuser
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_python_interpreter: /usr/bin/python3
      
      # VM-specific variables
      private_ip: 10.10.1.4
      
  vars:
    # Global variables
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

echo "✅ Inventory updated successfully!"
echo ""
echo "Next steps:"
echo "1. Set Tailscale OAuth credentials:"
echo "   export TAILSCALE_OAUTH_CLIENT_ID='your-client-id'"
echo "   export TAILSCALE_OAUTH_CLIENT_SECRET='your-client-secret'"
echo ""
echo "2. Run the playbook:"
echo "   ansible-playbook -i inventory.yml k3s-bootstrap-playbook.yml"
echo ""

