# GitOps Repository Structure

This document explains the complete GitOps structure for managing Ameciclo infrastructure.

## Repository Layout

```
groundwork/
├── azure/
│   ├── kubernetes/                    # ← All K8s configurations here
│   │   ├── kong/                      # Kong API Gateway (GitOps)
│   │   │   ├── kustomization.yaml     # Kustomize + Helm config
│   │   │   ├── values.yaml            # Kong Helm values
│   │   │   ├── argocd-application.yaml # ArgoCD Application
│   │   │   ├── README.md              # Kong documentation
│   │   │   ├── kong-deployment.yaml   # Legacy (reference only)
│   │   │   └── kong-namespace-secret.yaml # Legacy (reference only)
│   │   │
│   │   ├── atlas/                     # Atlas Microservices (ready for GitOps)
│   │   │   ├── cyclist-profile/
│   │   │   ├── cyclist-counts/
│   │   │   └── traffic-deaths/
│   │   │
│   │   ├── namespaces/                # Kubernetes Namespaces
│   │   ├── ingress/                   # Ingress Configuration
│   │   ├── kestra/                    # Kestra Workflow Orchestration
│   │   │
│   │   ├── README.md                  # Main K8s documentation
│   │   ├── GITOPS_SETUP.md            # GitOps setup guide
│   │   └── STRUCTURE.md               # This file
│   │
│   ├── *.tf                           # Terraform configurations
│   ├── terraform.tfvars               # Terraform variables
│   └── scripts/                       # Deployment scripts
│
├── ansible/
│   ├── k3s-playbook.yml               # K3s + ArgoCD + Kong installation
│   ├── k3s-inventory.yml              # K3s VM inventory
│   └── ...
│
└── ...
```

## How GitOps Works

### 1. **Developer Workflow**

```
Developer
    ↓
Edit files in azure/kubernetes/
    ↓
git add, commit, push
    ↓
GitHub Repository
```

### 2. **ArgoCD Workflow**

```
GitHub Repository
    ↓
ArgoCD watches for changes
    ↓
Detects new/updated files
    ↓
Renders Kustomize/Helm
    ↓
Applies to K3s cluster
    ↓
Kubernetes updates pods
```

### 3. **Result**

```
Git Repository ←→ K3s Cluster
(Source of Truth)  (Actual State)
     ↑                  ↓
     └──────────────────┘
     ArgoCD keeps them in sync!
```

## Kong GitOps Configuration

### Files

| File | Purpose |
|------|---------|
| `kustomization.yaml` | Kustomize configuration that renders Kong Helm chart |
| `values.yaml` | Kong Helm chart values (configuration) |
| `argocd-application.yaml` | Tells ArgoCD to manage Kong from this repo |
| `README.md` | Kong-specific documentation |

### How Kong is Deployed

1. **Kustomization** reads `values.yaml`
2. **Helm** renders Kong chart with those values
3. **ArgoCD** applies the rendered manifests to K3s
4. **Kubernetes** creates Kong pods and services

### Updating Kong

**Before (Manual):**
```
Edit Helm values → Run helm install → Manual sync
```

**After (GitOps):**
```
Edit values.yaml → git push → ArgoCD auto-syncs
```

## Adding New Applications

To add a new application (e.g., Kestra):

### 1. Create Directory Structure

```bash
mkdir -p azure/kubernetes/kestra
```

### 2. Create Kustomization

```yaml
# azure/kubernetes/kestra/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: kestra

helmCharts:
  - name: kestra
    repo: https://charts.kestra.io
    version: 1.0.0
    releaseName: kestra
    namespace: kestra
    valuesFile: values.yaml
```

### 3. Create Values File

```yaml
# azure/kubernetes/kestra/values.yaml
# Kestra Helm chart values
```

### 4. Create ArgoCD Application

```yaml
# azure/kubernetes/kestra/argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kestra
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/groundwork
    targetRevision: main
    path: azure/kubernetes/kestra
  destination:
    server: https://kubernetes.default.svc
    namespace: kestra
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 5. Commit and Push

```bash
git add azure/kubernetes/kestra/
git commit -m "feat: Add Kestra GitOps configuration"
git push origin main
```

### 6. ArgoCD Automatically Deploys

ArgoCD will detect the new application and deploy it!

## Best Practices

### 1. **Everything in Git**
- All configurations should be version controlled
- No manual kubectl apply commands
- All changes tracked in Git history

### 2. **Automated Sync**
- Let ArgoCD keep cluster in sync
- Don't manually edit cluster resources
- Changes should come from Git

### 3. **Secrets Management**
- Don't commit secrets to Git
- Use Azure Key Vault or Sealed Secrets
- Reference secrets in manifests

### 4. **Testing**
- Test changes in dev environment first
- Use Git branches for features
- Review changes before merging to main

### 5. **Documentation**
- Document why changes were made
- Keep README files updated
- Add comments to complex configurations

## Accessing Services

### ArgoCD
```
URL: http://10.20.1.4:80
Username: admin
Password: 5y5Xlzpdu2k215Gd
```

### Kong Proxy
```
URL: http://10.20.1.4:80
```

### Kong Admin API
```
URL: http://10.20.1.4:8001
```

### Kong Manager UI
```
URL: http://10.20.1.4:8002
```

## Useful Commands

```bash
# View all ArgoCD applications
kubectl get applications -n argocd

# View Kong application status
argocd app get kong

# Sync Kong manually
argocd app sync kong

# View Kong logs
kubectl logs -n kong -l app.kubernetes.io/name=kong

# Check Kong pods
kubectl get pods -n kong

# Describe Kong application
kubectl describe application -n argocd kong
```

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

