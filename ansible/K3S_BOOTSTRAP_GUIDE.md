# K3s Bootstrap Guide

Complete guide to bootstrap K3s with Tailscale Operator and ArgoCD using Ansible.

## Overview

This playbook automates the complete setup of:
- **K3s** - Lightweight Kubernetes distribution
- **Tailscale Operator** - VPN access to your cluster
- **ArgoCD** - GitOps continuous deployment

## Prerequisites

### 1. Azure VM Created
```bash
cd azure
terraform apply
```

Get the public IP:
```bash
terraform output vm_public_ip
```

### 2. SSH Key Setup
```bash
# Check if key exists
ls ~/.ssh/id_rsa

# If not, create one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 3. Ansible Installed
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt-get install ansible

# Verify
ansible --version
```

### 4. Tailscale OAuth Credentials
Get OAuth credentials from [Tailscale Admin Console](https://login.tailscale.com/admin/settings/oauth):

1. Go to Settings → OAuth
2. Create new OAuth client
3. Copy Client ID and Client Secret

## Setup Steps

### Step 1: Update Inventory

Edit `ansible/k3s-azure-inventory.yml` and update the IP:

```bash
# Get the IP from Terraform
AZURE_IP=$(cd azure && terraform output -raw vm_public_ip)
echo "VM IP: $AZURE_IP"

# Update inventory (macOS)
sed -i '' "s/20.171.92.187/$AZURE_IP/g" ansible/k3s-azure-inventory.yml

# Update inventory (Linux)
sed -i "s/20.171.92.187/$AZURE_IP/g" ansible/k3s-azure-inventory.yml
```

### Step 2: Test SSH Connection

```bash
ansible -i ansible/k3s-azure-inventory.yml all -m ping
```

Expected output:
```
ameciclo-k3s-azure | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 3: Run Bootstrap Playbook

```bash
# Set Tailscale OAuth credentials
export TAILSCALE_OAUTH_CLIENT_ID="your-client-id"
export TAILSCALE_OAUTH_CLIENT_SECRET="your-client-secret"

# Run the playbook
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-bootstrap-playbook.yml

# With verbose output (for debugging)
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-bootstrap-playbook.yml -v
```

The playbook will:
- ✅ Install K3s with disabled Traefik and ServiceLB
- ✅ Install Helm
- ✅ Deploy Tailscale Operator
- ✅ Deploy ArgoCD
- ✅ Configure Tailscale Ingress for ArgoCD
- ✅ Display access credentials

### Step 4: Access ArgoCD

After the playbook completes, you'll see:

```
ArgoCD Access:
- URL: https://argocd.armadillo-hamal.ts.net
- Username: admin
- Password: <GENERATED_PASSWORD>
```

Open the URL in your browser and log in.

### Step 5: Configure Local kubectl Access

```bash
# Copy kubeconfig from VM
scp -i ~/.ssh/id_rsa azureuser@<VM_IP>:/home/azureuser/.kube/config ~/.kube/config-k3s

# Set context
export KUBECONFIG=~/.kube/config-k3s
kubectl get nodes

# Or merge with existing kubeconfig
KUBECONFIG=~/.kube/config:~/.kube/config-k3s kubectl config view --flatten > ~/.kube/config-merged
mv ~/.kube/config-merged ~/.kube/config
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Azure VM (Ubuntu 22.04)         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  K3s Cluster                    │   │
│  │  (v1.32.4+k3s1)                 │   │
│  │                                 │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │ Tailscale Namespace      │   │   │
│  │  │ - Tailscale Operator     │   │   │
│  │  │ - Ingress Controller     │   │   │
│  │  └──────────────────────────┘   │   │
│  │                                 │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │ ArgoCD Namespace         │   │   │
│  │  │ - ArgoCD Server          │   │   │
│  │  │ - ArgoCD Repo Server     │   │   │
│  │  │ - Tailscale Ingress      │   │   │
│  │  └──────────────────────────┘   │   │
│  │                                 │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │ Your Services (GitOps)   │   │   │
│  │  │ - Kong                   │   │   │
│  │  │ - Other apps             │   │   │
│  │  └──────────────────────────┘   │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
         ↓
    Tailscale VPN
         ↓
   Your Local Machine
```

## Troubleshooting

### Playbook fails at Tailscale Operator
- Verify OAuth credentials are correct
- Check Tailscale admin console for the device

### ArgoCD not accessible
- Verify Tailscale Operator is running: `kubectl get pods -n tailscale`
- Check Ingress: `kubectl get ingress -n argocd`
- Verify DNS: `nslookup argocd.armadillo-hamal.ts.net`

### K3s not starting
- SSH into VM and check logs: `sudo journalctl -u k3s -n 50`
- Verify system resources: `free -h` and `df -h`

## Next Steps

1. **Configure Git Repository in ArgoCD**
   - Go to Settings → Repositories
   - Add your Git repository (e.g., Ameciclo/groundwork)

2. **Create Applications**
   - Create ArgoCD Applications for Kong and other services
   - Point to your Kubernetes manifests in Git

3. **Deploy Services**
   - Push manifests to Git
   - ArgoCD will automatically deploy them

## Files Reference

- `ansible/k3s-bootstrap-playbook.yml` - Main bootstrap playbook
- `ansible/k3s-azure-inventory.yml` - Inventory configuration
- `azure/k3s.tf` - Terraform K3s VM configuration

## Support

For issues:
1. Check playbook output for error messages
2. Run with verbose flag: `-v` or `-vv`
3. Check K3s logs: `sudo journalctl -u k3s`
4. Check Helm releases: `helm list -A`

