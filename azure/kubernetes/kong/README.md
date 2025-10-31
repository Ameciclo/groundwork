# Kong API Gateway - GitOps Configuration

This directory contains the GitOps configuration for Kong API Gateway managed by ArgoCD.

## Files

- **kustomization.yaml** - Kustomize configuration that renders the Kong Helm chart
- **values.yaml** - Kong Helm chart values (configuration)
- **argocd-application.yaml** - ArgoCD Application manifest (tells ArgoCD to manage Kong)
- **kong-deployment.yaml** - Legacy Kong deployment (for reference, not used with GitOps)
- **kong-namespace-secret.yaml** - Legacy secret configuration (for reference)

## How It Works

1. **ArgoCD watches this Git repository** for changes
2. **When you update files here**, ArgoCD automatically syncs Kong
3. **Kong is deployed via Helm** using the values in `values.yaml`
4. **PostgreSQL credentials** are managed via Kustomize secrets

## Setup Instructions

### 1. Update the ArgoCD Application

Edit `argocd-application.yaml` and replace:
```yaml
repoURL: https://github.com/yourusername/groundwork
```

With your actual GitHub repository URL.

### 2. Create the ArgoCD Application

```bash
kubectl apply -f argocd-application.yaml
```

Or use ArgoCD UI to create the application.

### 3. Monitor Kong Deployment

```bash
# Check Kong pods
kubectl get pods -n kong

# Check Kong services
kubectl get svc -n kong

# View Kong logs
kubectl logs -n kong -l app.kubernetes.io/name=kong
```

## Accessing Kong

### Kong Proxy (API Gateway)
```
http://10.20.1.4:80
https://10.20.1.4:443
```

### Kong Admin API
```
http://10.20.1.4:8001
```

### Kong Manager UI
```
http://10.20.1.4:8002
```

## Updating Kong Configuration

To update Kong:

1. Edit `values.yaml` in this directory
2. Commit and push to Git
3. ArgoCD will automatically sync the changes

Example: To change Kong log level:
```yaml
env:
  log_level: "debug"  # Changed from "notice"
```

## PostgreSQL Credentials

Credentials are defined in `kustomization.yaml`:
```yaml
secretGenerator:
  - name: kong-postgres-secret
    literals:
      - username=psqladmin
      - password=YourSecurePassword123!
      - host=ameciclo-postgres.postgres.database.azure.com
```

**Important:** For production, use a secrets management tool like:
- Azure Key Vault
- Sealed Secrets
- External Secrets Operator

## Troubleshooting

### Kong stuck in Init:1/2
Check if PostgreSQL is accessible:
```bash
kubectl logs -n kong -l app.kubernetes.io/name=kong -c wait-for-db
```

### ArgoCD not syncing
Check ArgoCD Application status:
```bash
kubectl get application -n argocd kong
kubectl describe application -n argocd kong
```

## Next Steps

1. Deploy your microservices (Atlas services)
2. Configure Kong routes to your services
3. Set up Kong plugins (authentication, rate limiting, etc.)

