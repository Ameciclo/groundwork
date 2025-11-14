# Tailscale Configuration

This directory contains Tailscale resources managed by ArgoCD.

## 🏗️ Architecture

**Bootstrap (Ansible):**
- Tailscale Operator installation
- OAuth credentials configuration

**GitOps (ArgoCD):**
- Tailscale Ingress for ArgoCD
- Tailscale Subnet Router
- Future Tailscale resources

## 📦 Resources

### 1. ArgoCD Ingress (`argocd-ingress.yaml`)

Makes ArgoCD accessible via Tailscale VPN:
- **URL**: `https://argocd.<your-tailnet>.ts.net`
- **IngressClass**: `tailscale`
- **Backend**: `argocd-server:443`

### 2. Subnet Router (`subnet-router.yaml`)

Advertises K3s networks to Tailscale:
- **Pod CIDR**: `10.42.0.0/16`
- **Service CIDR**: `10.43.0.0/16`

This allows direct access to pods and services from your local machine.

## 🚀 Deployment

### Automatic (via ArgoCD)

The Tailscale application is deployed automatically by ArgoCD:

```bash
kubectl apply -f kubernetes/argocd/infrastructure/tailscale.yaml
```

### Manual (for testing)

```bash
kubectl apply -k kubernetes/infrastructure/tailscale/
```

## 🔧 Configuration

### Accept Subnet Routes

On your local machine, accept the advertised routes:

```bash
sudo tailscale up --accept-routes
```

### Verify Connectivity

```bash
# Check Tailscale status
kubectl get connector -n tailscale

# Check ArgoCD ingress
kubectl get ingress -n argocd

# Check Tailscale services
kubectl get svc -n tailscale
```

### Access ArgoCD

1. Find your Tailscale hostname:
   ```bash
   kubectl get ingress argocd -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
   ```

2. Open in browser: `https://argocd.<your-tailnet>.ts.net`

3. Login:
   - Username: `admin`
   - Password: Get from secret:
     ```bash
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
     ```

## 🛠️ Troubleshooting

### ArgoCD Ingress not accessible

Check if Tailscale ingress is created:
```bash
kubectl get ingress -n argocd
kubectl describe ingress argocd -n argocd
```

Check Tailscale service:
```bash
kubectl get svc -n tailscale
kubectl logs -n tailscale -l app=operator
```

### Subnet routes not working

Check Connector status:
```bash
kubectl get connector k3s-subnet-router -n tailscale -o yaml
```

Make sure routes are accepted on your local machine:
```bash
tailscale status
sudo tailscale up --accept-routes
```

### Tailscale Operator not working

The operator is installed by Ansible during bootstrap. If it's not working:

1. Check operator logs:
   ```bash
   kubectl logs -n tailscale -l app=operator
   ```

2. Check OAuth secret:
   ```bash
   kubectl get secret operator-oauth -n tailscale
   ```

3. Re-run Ansible playbook if needed:
   ```bash
   cd automation/ansible
   ansible-playbook -i inventory.yml k3s-bootstrap-playbook.yml
   ```

## 📚 Additional Resources

- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- [Tailscale Ingress](https://tailscale.com/kb/1185/kubernetes)
- [Tailscale Subnet Routers](https://tailscale.com/kb/1019/subnets)

