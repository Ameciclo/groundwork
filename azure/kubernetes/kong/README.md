# Kong API Gateway - Manifest-Based Deployment

This directory contains all Kong API Gateway manifests managed by **ArgoCD** using **Kustomize**.

## Directory Structure

```
azure/kubernetes/kong/
├── README.md                    # This file
├── kustomization.yaml           # Kustomize configuration
├── argocd-application.yaml      # ArgoCD Application resource
├── namespace.yaml               # Kong namespace
├── secret.yaml                  # PostgreSQL credentials
├── helm-release.yaml            # Helm chart reference
├── service-admin.yaml           # Kong Admin API service
├── ingress-admin.yaml           # Kong Admin API ingress (Tailscale)
├── ingress-manager.yaml         # Kong Manager GUI ingress (Tailscale)
└── values.yaml                  # Helm values (reference only)
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    ArgoCD                               │
│  (Watches: azure/kubernetes/kong)                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  Kustomize                              │
│  (Builds manifests from kustomization.yaml)             │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
    ┌────────┐  ┌────────┐  ┌──────────┐
    │ Helm   │  │Secrets │  │Ingress & │
    │Release │  │Services│  │Services  │
    └────────┘  └────────┘  └──────────┘
        │            │            │
        └────────────┼────────────┘
                     ▼
        ┌─────────────────────────┐
        │   Kong Deployment       │
        │  - Kong Gateway Pod     │
        │  - PostgreSQL Backend   │
        │  - Tailscale Ingress    │
        └─────────────────────────┘
```

## Files Overview

### Core Manifests

#### `kustomization.yaml`
- Orchestrates all Kong resources
- Applies common labels to all resources
- Manages namespace and resource ordering

#### `argocd-application.yaml`
- ArgoCD Application resource
- Points to this directory for GitOps sync
- Enables automated deployment and pruning

#### `namespace.yaml`
- Kong namespace definition
- Labels for organization and management

#### `secret.yaml`
- PostgreSQL credentials
- Base64 encoded password
- Referenced by Kong deployment

#### `helm-release.yaml`
- Helm chart reference (Kong official chart)
- Chart version: 2.52.0
- Kong version: 3.9
- All configuration values inline

### Kong Services

#### `service-admin.yaml`
- Kong Admin API service
- Type: ClusterIP
- Port: 8001
- Accessed via Tailscale Ingress

#### `ingress-admin.yaml`
- Kong Admin API Ingress
- Ingress class: tailscale
- Hostname: kong-admin.armadillo-hamal.ts.net
- Private access only (Tailscale VPN)

#### `ingress-manager.yaml`
- Kong Manager GUI Ingress
- Ingress class: tailscale
- Hostname: kong-manager.armadillo-hamal.ts.net
- Private access only (Tailscale VPN)

### Reference Files

#### `values.yaml`
- Helm values reference
- Not used by deployment (values in helm-release.yaml)
- Useful for documentation and comparison

## Deployment Flow

### 1. Initial Deployment
```bash
# ArgoCD detects changes in this directory
# Kustomize builds all manifests
# Resources are applied in order:
# 1. Namespace
# 2. Secret
# 3. Helm Release (Kong)
# 4. Services
# 5. Ingresses
```

### 2. Updates
```bash
# Edit any manifest file
# Commit and push to Git
# ArgoCD automatically syncs
# Changes applied to cluster
```

### 3. Rollback
```bash
# Revert changes in Git
# ArgoCD automatically syncs
# Cluster reverts to previous state
```

## Access Information

### Kong Manager GUI
- **URL**: https://kong-manager.armadillo-hamal.ts.net
- **Access**: Tailscale VPN only
- **Port**: 8002

### Kong Admin API
- **URL**: https://kong-admin.armadillo-hamal.ts.net
- **Access**: Tailscale VPN only
- **Port**: 8001

### Kong Proxy
- **Service**: kong-kong-proxy (LoadBalancer with Tailscale)
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Access**: Tailscale VPN

## Configuration

### PostgreSQL Connection
- **Host**: ameciclo-postgres.privatelink.postgres.database.azure.com
- **Port**: 5432
- **User**: psqladmin
- **Database**: kong
- **SSL**: Enabled (sslmode=require, sslmode=verify-full)
- **Password**: Stored in `secret.yaml`

### Kong Settings
- **Replicas**: 1
- **Image**: kong:3.9
- **CPU Limit**: 500m
- **Memory Limit**: 512Mi
- **Log Level**: info

## Making Changes

### Update Kong Configuration
1. Edit `helm-release.yaml` (values section)
2. Commit and push to Git
3. ArgoCD automatically syncs

### Update Ingress Configuration
1. Edit `ingress-admin.yaml` or `ingress-manager.yaml`
2. Commit and push to Git
3. ArgoCD automatically syncs

### Update PostgreSQL Credentials
1. Edit `secret.yaml` (base64 encoded)
2. Commit and push to Git
3. ArgoCD automatically syncs
4. Kong pod will restart with new credentials

### Add New Services
1. Create new service manifest
2. Add to `kustomization.yaml` resources
3. Commit and push to Git
4. ArgoCD automatically syncs

## Verification

### Check Deployment Status
```bash
# Check ArgoCD application
kubectl get application -n argocd kong

# Check Kong pod
kubectl get pods -n kong

# Check services
kubectl get svc -n kong

# Check ingresses
kubectl get ingress -n kong
```

### View Logs
```bash
# Kong pod logs
kubectl logs -n kong deployment/kong-kong

# ArgoCD application logs
kubectl logs -n argocd deployment/argocd-application-controller
```

### Test Kong
```bash
# Test Admin API (from within cluster)
kubectl run -n kong test-curl --image=curlimages/curl --rm -it --restart=Never -- \
  curl -s http://kong-kong-admin:8001/status | jq

# Test Manager GUI (from Tailscale)
curl -k https://kong-manager.armadillo-hamal.ts.net
```

## Troubleshooting

### Kong Pod Not Starting
```bash
# Check pod status
kubectl describe pod -n kong <pod-name>

# Check logs
kubectl logs -n kong <pod-name>

# Common issues:
# - PostgreSQL connection failed: Check secret and network
# - Port already in use: Check other deployments
# - Image pull failed: Check image availability
```

### Ingress Not Working
```bash
# Check ingress status
kubectl describe ingress -n kong kong-admin

# Check Tailscale operator
kubectl get pods -n tailscale

# Verify DNS resolution
nslookup kong-admin.armadillo-hamal.ts.net
```

### PostgreSQL Connection Issues
```bash
# Test connection from pod
kubectl exec -n kong <pod-name> -- \
  psql -h ameciclo-postgres.privatelink.postgres.database.azure.com \
       -U psqladmin -d kong -c "SELECT version();"
```

## Best Practices

1. **Always use Git**: Never apply manifests directly with kubectl
2. **Test changes locally**: Use `kustomize build` to preview changes
3. **Use meaningful commit messages**: Describe what changed and why
4. **Keep secrets secure**: Use sealed-secrets or external secret management
5. **Monitor ArgoCD**: Check application status regularly
6. **Document changes**: Update this README when adding new resources

## Related Documentation

- [Kong Documentation](https://docs.konghq.com/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)

## Support

For issues or questions:
1. Check logs: `kubectl logs -n kong <pod-name>`
2. Check ArgoCD status: `kubectl describe application -n argocd kong`
3. Review this README
4. Check Kong documentation

