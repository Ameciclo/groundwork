# GitOps Setup Guide - Kong with ArgoCD

This guide explains how to set up Kong to be managed by ArgoCD using this Git repository.

## Current Status

✅ **K3s Cluster**: Running (v1.32.4+k3s1)
✅ **ArgoCD**: Running (v7.3.3)
✅ **Kong**: Installed via Helm (not yet managed by ArgoCD)

## Goal

Move Kong from direct Helm installation to **GitOps management** via ArgoCD.

## Step 1: Prepare the Repository

The Kong GitOps configuration is already in place:

```
azure/kubernetes/kong/
├── kustomization.yaml          # Kustomize + Helm configuration
├── values.yaml                 # Kong Helm chart values
├── argocd-application.yaml     # ArgoCD Application manifest
└── README.md                   # Kong documentation
```

## Step 2: Update the ArgoCD Application

Edit `azure/kubernetes/kong/argocd-application.yaml`:

```yaml
source:
  repoURL: https://github.com/yourusername/groundwork  # ← Update this!
  targetRevision: main
  path: azure/kubernetes/kong
```

Replace `yourusername` with your GitHub username.

## Step 3: Commit and Push to Git

```bash
cd /home/plpbs/Projetos/Ameciclo/groundwork

git add azure/kubernetes/kong/
git commit -m "feat: Add Kong GitOps configuration for ArgoCD"
git push origin main
```

## Step 4: Create the ArgoCD Application

Option A: **Using kubectl**
```bash
kubectl apply -f azure/kubernetes/kong/argocd-application.yaml
```

Option B: **Using ArgoCD CLI**
```bash
argocd app create kong \
  --repo https://github.com/yourusername/groundwork \
  --path azure/kubernetes/kong \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace kong \
  --auto-prune \
  --self-heal
```

Option C: **Using ArgoCD UI**
1. Go to http://10.20.1.4:80
2. Click "New App"
3. Fill in the form:
   - Application Name: `kong`
   - Project: `default`
   - Repository URL: `https://github.com/yourusername/groundwork`
   - Path: `azure/kubernetes/kong`
   - Destination: `https://kubernetes.default.svc` / `kong`
4. Click "Create"

## Step 5: Monitor Kong Deployment

```bash
# Check ArgoCD application status
kubectl get application -n argocd kong

# View detailed status
argocd app get kong

# Check Kong pods
kubectl get pods -n kong

# View Kong logs
kubectl logs -n kong -l app.kubernetes.io/name=kong
```

## Step 6: Verify Kong is Running

```bash
# Check Kong services
kubectl get svc -n kong

# Test Kong proxy
curl http://10.20.1.4:80/status

# Test Kong admin API
curl http://10.20.1.4:8001/status
```

## Updating Kong Configuration

Now that Kong is managed by ArgoCD, you can update it by:

### 1. Edit Configuration Files

Edit `azure/kubernetes/kong/values.yaml`:

```yaml
env:
  log_level: "debug"  # Change from "notice"
```

### 2. Commit and Push

```bash
git add azure/kubernetes/kong/values.yaml
git commit -m "chore: Update Kong log level to debug"
git push origin main
```

### 3. ArgoCD Syncs Automatically

ArgoCD will detect the change and automatically update Kong!

Or manually sync:
```bash
argocd app sync kong
```

## Troubleshooting

### Kong pods not starting

Check the logs:
```bash
kubectl logs -n kong -l app.kubernetes.io/name=kong -c wait-for-db
```

If PostgreSQL connection fails, verify:
1. PostgreSQL firewall rules allow K3s subnet (10.20.1.0/24)
2. PostgreSQL credentials in `kustomization.yaml` are correct

### ArgoCD not syncing

Check application status:
```bash
kubectl describe application -n argocd kong
```

Check ArgoCD logs:
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Git repository not accessible

Verify:
1. Repository URL is correct
2. Repository is public (or add SSH key to ArgoCD)
3. Branch exists (default: `main`)

## Next Steps

1. **Deploy Atlas Microservices** - Create ArgoCD applications for your services
2. **Configure Kong Routes** - Set up Kong to route traffic to your services
3. **Add Monitoring** - Deploy Prometheus and Grafana
4. **Set up Secrets Management** - Use Azure Key Vault or Sealed Secrets

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kong Helm Chart](https://github.com/Kong/charts)
- [Kong Documentation](https://docs.konghq.com/)

