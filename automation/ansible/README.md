# Ansible Automation for K3s VM

This directory contains Ansible playbooks for provisioning and managing the K3s VM.

## 📋 Prerequisites

1. **Ansible installed**:
   ```bash
   # macOS
   brew install ansible
   
   # Ubuntu/Debian
   sudo apt install ansible
   ```

2. **Infrastructure deployed**:
   ```bash
   cd infrastructure/pulumi
   pulumi up
   ```

3. **Tailscale OAuth credentials**:
   - Go to https://login.tailscale.com/admin/settings/oauth
   - Create OAuth client with scope: `devices:write`
   - Save Client ID and Client Secret

## 🚀 Quick Start

### Step 1: Update Inventory

Get the K3s VM public IP from Pulumi:
```bash
cd infrastructure/pulumi
pulumi stack output k3sPublicIp
```

Update `inventory.yml` with the IP address:
```yaml
ansible_host: <k3s-public-ip>
```

### Step 2: Set Environment Variables

```bash
export TAILSCALE_OAUTH_CLIENT_ID="your-client-id"
export TAILSCALE_OAUTH_CLIENT_SECRET="your-client-secret"
```

### Step 3: Run the Playbook

```bash
cd automation/ansible
ansible-playbook -i inventory.yml k3s-bootstrap-playbook.yml
```

## 📦 What Gets Installed (Bootstrap)

Ansible installs the **minimal bootstrap** components:

- ✅ **K3s** v1.32.4+k3s1 - Lightweight Kubernetes
- ✅ **Helm** v3.14.0 - Package manager
- ✅ **Tailscale Operator** - Secure networking (operator only)
- ✅ **ArgoCD** v7.3.3 - GitOps deployment
- ✅ **PostgreSQL Client** - Database access
- ✅ **btop** - System monitor
- ✅ **System utilities** - curl, wget, git, jq, etc.

**Note:** Tailscale resources (Ingress, Subnet Router) are managed by ArgoCD, not Ansible.
This follows GitOps best practices where Ansible bootstraps, ArgoCD manages.

## 🔧 Configuration

### Variables (in playbook)

```yaml
k3s_version: "v1.32.4+k3s1"
helm_version: "v3.14.0"
argocd_version: "7.3.3"
pod_cidr: "10.42.0.0/16"        # K3s pod network
service_cidr: "10.43.0.0/16"    # K3s service network
```

### Optional Components

Disable components by setting to `false`:
```yaml
install_tailscale_operator: false
install_argocd: false
install_tailscale_subnet_router: false
```

## 📝 Post-Installation

### Step 1: Deploy Tailscale Resources via ArgoCD

After Ansible completes, deploy the Tailscale ArgoCD application:

```bash
# SSH into the VM
ssh azureuser@<k3s-ip>

# Deploy Tailscale application
kubectl apply -f /path/to/groundwork/kubernetes/argocd/infrastructure/tailscale.yaml

# Or from your local machine (if you have kubeconfig)
kubectl apply -f kubernetes/argocd/infrastructure/tailscale.yaml
```

This will create:
- ✅ Tailscale Ingress for ArgoCD
- ✅ Tailscale Subnet Router

### Step 2: Accept Tailscale Routes

On your local machine:
```bash
sudo tailscale up --accept-routes
```

This allows access to:
- K3s pods: `10.42.0.0/16`
- K3s services: `10.43.0.0/16`

### Step 3: Access ArgoCD

1. **Get ArgoCD password**:
   ```bash
   ssh azureuser@<k3s-ip> "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
   ```

2. **Access via Tailscale**:
   - URL: `https://argocd.<your-tailnet>.ts.net`
   - Username: `admin`
   - Password: (from step 1)

### Access K3s API

```bash
# Copy kubeconfig from VM
scp azureuser@<k3s-ip>:~/.kube/config ~/.kube/k3s-config

# Use it
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
```

## 🛠️ Troubleshooting

### Playbook fails with "TAILSCALE_OAUTH_CLIENT_ID not set"

Make sure environment variables are exported:
```bash
export TAILSCALE_OAUTH_CLIENT_ID="your-id"
export TAILSCALE_OAUTH_CLIENT_SECRET="your-secret"
```

### K3s installation fails

SSH into the VM and check logs:
```bash
ssh azureuser@<k3s-ip>
sudo journalctl -u k3s -f
```

### ArgoCD not accessible

Check if Tailscale ingress is created:
```bash
kubectl get ingress -n argocd
kubectl get svc -n tailscale
```

## 📚 Additional Resources

- [K3s Documentation](https://docs.k3s.io/)
- [Tailscale Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

