# 🚀 Quick Start Guide - Ansible Provisioning

## Prerequisites Checklist

- [ ] Infrastructure deployed with Pulumi (`pulumi up`)
- [ ] Ansible installed (`brew install ansible` or `sudo apt install ansible`)
- [ ] Tailscale OAuth credentials ready

## Step-by-Step Instructions

### 1. Get Tailscale OAuth Credentials

1. Go to https://login.tailscale.com/admin/settings/oauth
2. Click **"Generate OAuth client"**
3. Set scope: **`devices:write`**
4. Copy **Client ID** and **Client Secret**

### 2. Update Inventory

```bash
cd automation/ansible
./update-inventory.sh
```

This automatically fetches the K3s VM IP from Pulumi and updates `inventory.yml`.

### 3. Set Environment Variables

```bash
export TAILSCALE_OAUTH_CLIENT_ID="tskey-client-..."
export TAILSCALE_OAUTH_CLIENT_SECRET="tskey-..."
```

### 4. Test Connectivity

```bash
ansible -i inventory.yml k3s-vm -m ping
```

Expected output:
```
k3s-vm | SUCCESS => {
    "ping": "pong"
}
```

### 5. Run the Playbook

```bash
ansible-playbook -i inventory.yml k3s-bootstrap-playbook.yml
```

This will take **~10-15 minutes** and install:
- ✅ K3s v1.32.4+k3s1
- ✅ Helm v3.14.0
- ✅ Tailscale Operator (bootstrap only)
- ✅ ArgoCD v7.3.3
- ✅ PostgreSQL client
- ✅ btop system monitor

**Note:** Tailscale Ingress and Subnet Router are NOT installed by Ansible.
They will be managed by ArgoCD in the next step.

### 6. Deploy Tailscale Resources via ArgoCD

After Ansible completes, deploy Tailscale configuration:

```bash
# SSH into the VM
ssh azureuser@$(cd ../../infrastructure/pulumi && pulumi stack output k3sPublicIp)

# Deploy Tailscale ArgoCD application
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tailscale
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ameciclo/groundwork.git
    targetRevision: main
    path: kubernetes/infrastructure/tailscale
  destination:
    server: https://kubernetes.default.svc
    namespace: tailscale
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Wait for Tailscale resources to be created
kubectl wait --for=condition=Ready connector/k3s-subnet-router -n tailscale --timeout=300s
```

### 7. Post-Installation

#### Accept Tailscale Routes

On your local machine:
```bash
sudo tailscale up --accept-routes
```

#### Get ArgoCD Password

```bash
ssh azureuser@$(cd ../../infrastructure/pulumi && pulumi stack output k3sPublicIp) \
  "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
```

#### Access ArgoCD

1. Wait for Tailscale Ingress to be ready:
   ```bash
   kubectl get ingress argocd -n argocd
   ```

2. Open in browser: `https://argocd.<your-tailnet>.ts.net`

3. Login:
   - Username: `admin`
   - Password: (from step above)

## Troubleshooting

### "TAILSCALE_OAUTH_CLIENT_ID not set"

Make sure you exported the environment variables:
```bash
export TAILSCALE_OAUTH_CLIENT_ID="tskey-client-..."
export TAILSCALE_OAUTH_CLIENT_SECRET="tskey-..."
```

### "Failed to connect to the host via ssh"

Check if the VM is running:
```bash
cd ../../infrastructure/pulumi
pulumi stack output k3sPublicIp
ssh azureuser@<ip>
```

### K3s not starting

SSH into the VM and check logs:
```bash
ssh azureuser@<k3s-ip>
sudo journalctl -u k3s -f
```

### ArgoCD not accessible

Check Tailscale ingress:
```bash
kubectl get ingress -n argocd
kubectl get svc -n tailscale
```

## What's Next?

After successful provisioning:

1. **Configure ArgoCD** with your Git repository
2. **Deploy applications** (Strapi, Atlas, Zitadel)
3. **Set up database credentials** in Infisical
4. **Configure DNS** for your domains
5. **Set up SSL certificates** with Traefik

## Useful Commands

```bash
# Check K3s status
ssh azureuser@<k3s-ip> "kubectl get nodes"

# View all pods
ssh azureuser@<k3s-ip> "kubectl get pods -A"

# System monitor
ssh azureuser@<k3s-ip> "btop"

# Database access
ssh azureuser@<k3s-ip> "psql -h ameciclo-postgres.postgres.database.azure.com -U psqladmin -d postgres"
```

