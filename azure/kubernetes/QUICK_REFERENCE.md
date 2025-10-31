# Quick Reference Card

## URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **ArgoCD** | http://10.20.1.4:80 | GitOps management |
| **Kong Proxy** | http://10.20.1.4:80 | API gateway |
| **Kong Admin** | http://10.20.1.4:8001 | Admin API |
| **Kong Manager** | http://10.20.1.4:8002 | Web UI |

## Credentials

| Service | Username | Password |
|---------|----------|----------|
| **ArgoCD** | admin | 5y5Xlzpdu2k215Gd |
| **PostgreSQL** | psqladmin | YourSecurePassword123! |

## Common Commands

### ArgoCD

```bash
# View all applications
kubectl get applications -n argocd

# View Kong status
argocd app get kong

# Sync Kong manually
argocd app sync kong

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Kong

```bash
# Check Kong pods
kubectl get pods -n kong

# View Kong logs
kubectl logs -n kong -l app.kubernetes.io/name=kong

# Test Kong
curl http://10.20.1.4:8001/status

# Get Kong services
kubectl get svc -n kong
```

### Kubernetes

```bash
# Get all pods
kubectl get pods -A

# Get all services
kubectl get svc -A

# Get all applications
kubectl get applications -n argocd

# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>

# Port forward
kubectl port-forward svc/<service> <local-port>:<remote-port> -n <namespace>
```

## File Locations

| File | Purpose |
|------|---------|
| `azure/kubernetes/kong/kustomization.yaml` | Kustomize config |
| `azure/kubernetes/kong/values.yaml` | Kong values |
| `azure/kubernetes/kong/argocd-application.yaml` | ArgoCD app |
| `azure/kubernetes/README.md` | Main docs |
| `azure/kubernetes/GITOPS_SETUP.md` | Setup guide |
| `azure/kubernetes/ACCESS_GUIDE.md` | URLs & credentials |
| `azure/kubernetes/ARCHITECTURE.md` | Architecture |

## Updating Kong

1. Edit `azure/kubernetes/kong/values.yaml`
2. `git add azure/kubernetes/kong/values.yaml`
3. `git commit -m "..."`
4. `git push origin main`
5. ArgoCD syncs automatically ✨

## Troubleshooting

### Kong not starting
```bash
kubectl logs -n kong -l app.kubernetes.io/name=kong -c wait-for-db
```

### ArgoCD not syncing
```bash
kubectl describe application -n argocd kong
```

### Check PostgreSQL connection
```bash
kubectl get secret -n kong kong-postgres-secret -o yaml
```

### SSH to K3s VM
```bash
ssh -i ~/.ssh/id_rsa azureuser@20.172.9.53
```

## System Info

| Component | Value |
|-----------|-------|
| **K3s Version** | v1.32.4+k3s1 |
| **ArgoCD Version** | 7.3.3 |
| **Kong Version** | 3.4 |
| **PostgreSQL** | 16 |
| **VM Size** | Standard_B2as_v2 |
| **RAM** | 8 GB |
| **vCPU** | 2 |

## Resource Usage

| Component | Memory | CPU |
|-----------|--------|-----|
| **ArgoCD** | ~167 MB | 1% |
| **Kube-system** | ~46 MB | 1% |
| **Kong** | (initializing) | - |
| **Available** | ~6.2 GB | 98% |

## Network Ports

| Port | Service | Type |
|------|---------|------|
| 80 | Kong Proxy / ArgoCD | HTTP |
| 443 | Kong Proxy | HTTPS |
| 8001 | Kong Admin | HTTP |
| 8002 | Kong Manager | HTTP |
| 6443 | K3s API | HTTPS |

## PostgreSQL

| Property | Value |
|----------|-------|
| **FQDN** | ameciclo-postgres.postgres.database.azure.com |
| **Port** | 5432 |
| **Admin User** | psqladmin |
| **Databases** | kong, atlas |

## Cost

| Component | Cost/Month |
|-----------|-----------|
| K3s VM | ~$19 |
| PostgreSQL | ~$28 |
| **Total** | **~$47** |

## Documentation

- **DEPLOYMENT_COMPLETE.md** - Overview
- **ACCESS_GUIDE.md** - URLs & credentials
- **GITOPS_SETUP.md** - Setup steps
- **ARCHITECTURE.md** - System design
- **STRUCTURE.md** - Repository layout
- **QUICK_REFERENCE.md** - This file

## Next Steps

1. Update repository URL in `argocd-application.yaml`
2. Commit and push to Git
3. Create ArgoCD application
4. Monitor Kong deployment
5. Deploy Atlas microservices
6. Configure Kong routes

---

**Everything you need to know on one page!** 📋

