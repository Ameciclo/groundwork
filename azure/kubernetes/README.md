# Kubernetes GitOps Configuration

This directory contains all Kubernetes manifests and Helm configurations managed by **ArgoCD**.

## Directory Structure

```
kubernetes/
├── namespaces/          # Kubernetes namespaces
├── atlas/               # Atlas microservices
├── kestra/              # Kestra workflow orchestration
├── monitoring/          # Prometheus, Grafana, Loki
└── ingress/             # Ingress configuration
```

## GitOps Workflow

**Everything is managed by ArgoCD!**

1. **Developer updates files** in this directory
2. **Commits and pushes to Git**
3. **ArgoCD automatically detects changes**
4. **Kubernetes cluster is updated automatically**

This ensures your cluster state always matches Git! 🚀

## Accessing ArgoCD

**URL:** http://10.20.1.4:80

**Credentials:**
- Username: `admin`
- Password: `5y5Xlzpdu2k215Gd`

From here you can:
- View all deployed applications
- Sync applications manually
- View deployment history
- Monitor application health

## Prerequisites

- K3s cluster deployed with ArgoCD
- kubectl configured to access your cluster
- Helm 3.x installed (for some deployments)

## Deployment with ArgoCD

ArgoCD automatically manages deployments! Just:

1. **Update files** in this directory
2. **Commit and push to Git**
3. **ArgoCD syncs automatically** (or manually via UI)

### Manual Deployment (if needed)

```bash
# Sync all applications
argocd app sync --all

# Sync specific application
argocd app sync kong

# View application status
argocd app get kong
```

## Quick Start

### 1. View ArgoCD Applications

```bash
# List all applications
kubectl get applications -n argocd

# View Kong application status
argocd app get kong
```

### 2. Sync Applications

```bash
# Sync Kong (if not auto-syncing)
argocd app sync kong

# Sync all applications
argocd app sync --all
```

### 3. Verify Deployment

```bash
# Check Kong pods
kubectl get pods -n kong

# Check Kong services
kubectl get svc -n kong

# View Kong logs
kubectl logs -n kong -l app.kubernetes.io/name=kong
```

### 4. Update Configuration

To update any service:
1. Edit the configuration files in this directory
2. Commit and push to Git
3. ArgoCD will automatically sync (or manually sync via UI)

## Configuration

### Database Connection

Update the database connection string in your manifests:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: postgres-credentials
        key: connection-string
```

### Container Images

Update image references to use your Azure Container Registry:

```yaml
image: amecicloregistry.azurecr.io/atlas/cyclist-profile:latest
imagePullSecrets:
  - name: acr-secret
```

### Storage

Services requiring persistent storage use PersistentVolumeClaims:

```yaml
volumeMounts:
  - name: data
    mountPath: /data
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: service-data-pvc
```

## Monitoring

### View Logs

```bash
kubectl logs -f deployment/cyclist-profile -n ameciclo
```

### Port Forward to Services

```bash
# Kong Admin
kubectl port-forward svc/kong-admin 8001:8001 -n ameciclo

# Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment cyclist-profile --replicas=3 -n ameciclo
```

### Horizontal Pod Autoscaler

```bash
kubectl autoscale deployment cyclist-profile --min=2 --max=5 -n ameciclo
```

## Troubleshooting

### Pod Not Starting

```bash
kubectl describe pod <pod-name> -n ameciclo
kubectl logs <pod-name> -n ameciclo
```

### Service Not Accessible

```bash
kubectl get svc -n ameciclo
kubectl describe svc <service-name> -n ameciclo
```

### Database Connection Issues

```bash
# Test connectivity from a pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside the pod:
nc -zv ameciclo-postgres.postgres.database.azure.com 5432
```

## Next Steps

1. Set up CI/CD pipelines to build and push images to ACR
2. Configure Ingress with SSL/TLS certificates
3. Set up monitoring and alerting
4. Configure backup and disaster recovery
5. Implement GitOps with ArgoCD or Flux

## References

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [Helm Documentation](https://helm.sh/docs/)

