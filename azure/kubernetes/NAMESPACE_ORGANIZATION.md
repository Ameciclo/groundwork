# Kubernetes Namespace Organization

## Overview

Ameciclo's K3s cluster uses namespaces to organize infrastructure and applications.

## Namespace Structure

### Infrastructure Namespaces (Managed by Helm/ArgoCD)

#### `argocd` - GitOps Management
- **Purpose**: GitOps continuous deployment
- **Components**: ArgoCD Server, Controller, Repo Server, Redis
- **Access**:
  - HTTPS: https://argocd.tail118de4.ts.net (via Tailscale)
  - HTTP: http://10.20.1.4:80 (direct IP)
  - Short: https://argocd (requires /etc/hosts entry)
- **Credentials**: admin / 5y5Xlzpdu2k215Gd
- **Managed by**: Helm chart

#### `kong` - API Gateway
- **Purpose**: API Gateway and reverse proxy
- **Components**: Kong API Gateway, Kong Manager
- **Access**: 
  - Kong Proxy: http://10.20.1.4:30292 (NodePort)
  - Kong Manager: http://10.20.1.4:32147 (NodePort)
- **Database**: PostgreSQL (Azure Managed, private network)
- **Managed by**: Helm chart via ArgoCD

#### `tailscale` - VPN & Networking
- **Purpose**: Secure VPN access to cluster
- **Components**: Tailscale Operator, Connector, Service Proxies
- **Connector**: Advertises routes 10.20.0.0/16 and 10.43.0.0/16
- **Managed by**: Helm chart

#### `kube-system` - System Components
- **Purpose**: Kubernetes system components
- **Components**: CoreDNS, Metrics Server, Local Path Provisioner
- **Do not modify**: System managed

### Application Namespaces

#### `production` - Production Applications
- **Purpose**: Production workloads and services
- **Default namespace**: Yes (set in kubeconfig context)
- **Usage**: Deploy your applications here
- **Example**: Microservices, APIs, web apps

#### `default` - System Default
- **Purpose**: Kubernetes default namespace
- **Status**: Empty (not used)
- **Note**: Kept for compatibility but not used in Ameciclo

---

## Namespace Organization Diagram

```
ameciclo-azure-cluster
│
├── Infrastructure (System-managed)
│   ├── kube-system
│   ├── kube-public
│   └── kube-node-lease
│
├── Infrastructure (Ameciclo-managed)
│   ├── argocd (GitOps)
│   ├── kong (API Gateway)
│   └── tailscale (VPN)
│
└── Applications
    └── production (Your workloads)
```

---

## Common Commands

### View Namespaces
```bash
# List all namespaces
kubectl get namespaces

# Get current default namespace
kubectl config view | grep namespace
```

### Work with Namespaces
```bash
# Get pods in production namespace
kubectl get pods -n production

# Get pods in all namespaces
kubectl get pods -A

# Deploy to production
kubectl apply -f app.yaml -n production

# Set default namespace
kubectl config set-context ameciclo-azure-cluster --namespace=production
```

### Using k9s
```bash
# Switch namespaces in k9s
# Press : then type "ns" and select namespace

# View all namespaces
# Press : then type "all"
```

---

## Best Practices

### 1. Always Deploy to `production`
```bash
# ✅ Correct
kubectl apply -f app.yaml -n production

# ❌ Avoid
kubectl apply -f app.yaml -n default
```

### 2. Use Labels for Organization
```yaml
metadata:
  labels:
    app: my-service
    environment: production
    team: ameciclo
    managed-by: argocd
```

### 3. Use ArgoCD for Deployments
Instead of manual `kubectl apply`, use ArgoCD Applications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/ameciclo/groundwork
    targetRevision: main
    path: apps/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4. Resource Quotas (Optional)
Limit resources per namespace:

```bash
# Set memory limit for production
kubectl set resources namespace production --hard=memory=8Gi
```

---

## Future Expansion

When you need additional environments:

```bash
# Create staging namespace
kubectl create namespace staging

# Create development namespace
kubectl create namespace development

# Create monitoring namespace
kubectl create namespace monitoring
```

Then deploy to specific namespaces:
```bash
kubectl apply -f app.yaml -n staging
kubectl apply -f app.yaml -n production
```

---

## Summary

- **Infrastructure**: argocd, kong, tailscale (managed by Helm/ArgoCD)
- **Applications**: production (your workloads)
- **Default namespace**: production
- **Management**: Use ArgoCD for GitOps deployments

