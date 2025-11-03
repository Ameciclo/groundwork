# Quick Start Guide

## One-Command Bootstrap

```bash
# 1. Set Tailscale OAuth credentials
export TAILSCALE_OAUTH_CLIENT_ID="your-client-id"
export TAILSCALE_OAUTH_CLIENT_SECRET="your-client-secret"

# 2. Get Azure VM IP
AZURE_IP=$(cd azure && terraform output -raw vm_public_ip)

# 3. Update inventory
sed -i "s/20.171.92.187/$AZURE_IP/g" ansible/k3s-azure-inventory.yml

# 4. Run bootstrap
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-bootstrap-playbook.yml
```

## Access Services

### ArgoCD
```bash
# URL
https://argocd.armadillo-hamal.ts.net

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Kong Admin API
```bash
# URL
https://kong-admin.armadillo-hamal.ts.net

# Test
curl -k https://kong-admin.armadillo-hamal.ts.net/
```

### Kong Manager GUI
```bash
# URL
https://kong-manager.armadillo-hamal.ts.net
```

## Common Commands

### Cluster Status
```bash
# Get nodes
kubectl get nodes

# Get all pods
kubectl get pods -A

# Get services
kubectl get svc -A

# Get ingresses
kubectl get ingress -A
```

### Tailscale Status
```bash
# Get Tailscale operator pods
kubectl get pods -n tailscale

# Get Tailscale devices
tailscale status
```

### ArgoCD Status
```bash
# Get ArgoCD pods
kubectl get pods -n argocd

# Get ArgoCD applications
kubectl get applications -n argocd

# Get ArgoCD ingress
kubectl get ingress -n argocd
```

### Kong Status
```bash
# Get Kong pods
kubectl get pods -n kong

# Get Kong services
kubectl get svc -n kong

# Get Kong ingresses
kubectl get ingress -n kong

# Check Kong admin API
curl -k https://kong-admin.armadillo-hamal.ts.net/
```

## Deploy New Service via ArgoCD

### 1. Create Kubernetes Manifests
```bash
mkdir -p azure/kubernetes/my-service
cat > azure/kubernetes/my-service/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
  namespace: my-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-service
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
      - name: my-service
        image: my-image:latest
        ports:
        - containerPort: 8080
EOF
```

### 2. Create ArgoCD Application
```bash
cat > azure/kubernetes/my-service/argocd-application.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-service
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ameciclo/groundwork
    targetRevision: main
    path: azure/kubernetes/my-service
  destination:
    server: https://kubernetes.default.svc
    namespace: my-service
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
```

### 3. Push to Git
```bash
git add azure/kubernetes/my-service/
git commit -m "Add my-service deployment"
git push
```

### 4. ArgoCD will automatically deploy!

## Troubleshooting

### Service not accessible
```bash
# Check if service exists
kubectl get svc -n <namespace>

# Check if ingress exists
kubectl get ingress -n <namespace>

# Check ingress details
kubectl describe ingress <ingress-name> -n <namespace>

# Check DNS resolution
nslookup <service-name>.armadillo-hamal.ts.net
```

### Pod not starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check pod logs
kubectl logs <pod-name> -n <namespace>

# Check previous logs (if crashed)
kubectl logs <pod-name> -n <namespace> --previous
```

### ArgoCD not syncing
```bash
# Check application status
kubectl describe application <app-name> -n argocd

# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Manually sync
argocd app sync <app-name>
```

## Environment Variables

### Required for Bootstrap
```bash
TAILSCALE_OAUTH_CLIENT_ID=your-client-id
TAILSCALE_OAUTH_CLIENT_SECRET=your-client-secret
```

### Optional for kubectl
```bash
export KUBECONFIG=~/.kube/config-k3s
```

## Useful Links

- [K3s Docs](https://docs.k3s.io/)
- [Tailscale Operator](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Kong Docs](https://docs.konghq.com/)
- [Kubernetes Docs](https://kubernetes.io/docs/)

## Support

For issues, check:
1. Playbook output for error messages
2. Pod logs: `kubectl logs <pod-name> -n <namespace>`
3. Describe resources: `kubectl describe <resource-type> <name> -n <namespace>`
4. Check events: `kubectl get events -n <namespace>`

