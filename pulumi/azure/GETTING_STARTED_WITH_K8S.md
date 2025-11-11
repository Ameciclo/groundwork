# Getting Started with Kubernetes on Pulumi

Quick start guide for deploying Ameciclo infrastructure with Kubernetes support.

## Prerequisites

- Node.js v18+
- Pulumi CLI
- Azure CLI
- SSH key pair
- Tailscale OAuth credentials (optional, for Tailscale Operator)

## Quick Start (5 minutes)

### 1. Setup

```bash
cd pulumi/azure
npm install
az login
pulumi login
```

### 2. Create Stack

```bash
pulumi stack init prod
cp Pulumi.prod.yaml.example Pulumi.prod.yaml
```

### 3. Configure Secrets

```bash
# PostgreSQL password
pulumi config set --secret groundwork-azure:postgresql_admin_password <password>

# SSH keys
pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
pulumi config set --secret groundwork-azure:admin_ssh_private_key "$(cat ~/.ssh/id_rsa)"

# ArgoCD password
pulumi config set --secret groundwork-azure:argocd_admin_password <password>

# Tailscale (optional)
pulumi config set --secret groundwork-azure:tailscale_oauth_client_id <id>
pulumi config set --secret groundwork-azure:tailscale_oauth_client_secret <secret>
```

### 4. Deploy

```bash
pulumi preview
pulumi up
```

### 5. Verify

```bash
# Get outputs
pulumi stack output

# Access ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Visit https://localhost:8080
```

## What Gets Deployed

### Infrastructure (Pulumi)
- Azure Resource Group
- Virtual Network (10.10.0.0/16)
- K3s VM (Ubuntu 22.04)
- PostgreSQL Database
- Network Security Groups

### Kubernetes (Pulumi)
- Kubernetes namespaces
- ArgoCD (GitOps controller)
- Tailscale Operator (networking)
- ArgoCD Applications

### Applications (ArgoCD)
- Strapi (CMS)
- Atlas (API)
- Kong (API Gateway)
- Kestra (Workflow)

## Key Commands

```bash
# Preview changes
pulumi preview

# Deploy
pulumi up

# View outputs
pulumi stack output

# Get specific output
pulumi stack output k3sVmPublicIp

# Destroy (careful!)
pulumi destroy

# View stack info
pulumi stack
```

## Accessing Applications

### ArgoCD UI
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
# https://localhost:8080
# Username: admin
# Password: (from config)
```

### Application Pods
```bash
# Check status
kubectl get pods -n strapi
kubectl get pods -n atlas
kubectl get pods -n kong
kubectl get pods -n kestra

# View logs
kubectl logs -n strapi -l app.kubernetes.io/name=strapi
```

### SSH to VM
```bash
# Get IP
VM_IP=$(pulumi stack output k3sVmPublicIp)

# SSH
ssh -i ~/.ssh/id_rsa azureuser@$VM_IP

# Check K3s
sudo systemctl status k3s
sudo kubectl get nodes
```

## Configuration

Edit `Pulumi.prod.yaml`:

```yaml
groundwork-azure:environment: production
groundwork-azure:k3s_vm_size: Standard_B2as_v2
groundwork-azure:argocd_version: "7.3.3"
groundwork-azure:git_repo_url: https://github.com/Ameciclo/groundwork.git
```

## Troubleshooting

### Build Errors
```bash
npm install
npm run build
```

### Deployment Fails
```bash
# Check Azure login
az account show

# Check Pulumi state
pulumi stack export > backup.json
```

### Kubernetes Not Ready
```bash
# SSH to VM
ssh azureuser@<IP>

# Check K3s
sudo systemctl status k3s
sudo kubectl get nodes
```

## Documentation

- **README.md** - Full documentation
- **KUBERNETES_DEPLOYMENT.md** - Kubernetes details
- **INTEGRATION_WITH_ANSIBLE.md** - Ansible integration
- **KUBERNETES_SETUP_SUMMARY.md** - What was added

## Next Steps

1. Deploy infrastructure
2. Run Ansible playbook (if needed)
3. Access ArgoCD UI
4. Monitor applications
5. Configure Tailscale for secure access

## Support

For issues, check:
1. Build errors: `npm run build`
2. Deployment: `pulumi preview`
3. Kubernetes: `kubectl get pods -A`
4. Logs: `pulumi logs`

## Cost Estimate

- K3s VM: ~$45/month
- PostgreSQL: ~$25/month
- Networking: ~$8/month
- **Total**: ~$78/month

