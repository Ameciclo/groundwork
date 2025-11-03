# Kong Quick Reference Guide

## Access Kong Services

### Kong Manager GUI
```bash
# Open in browser (requires Tailscale VPN)
https://kong-manager.armadillo-hamal.ts.net
```

### Kong Admin API
```bash
# Test Kong Admin API
curl -k https://kong-admin.armadillo-hamal.ts.net/status | jq

# Get Kong version
curl -k https://kong-admin.armadillo-hamal.ts.net/ | jq '.version'

# List services
curl -k https://kong-admin.armadillo-hamal.ts.net/services | jq

# List routes
curl -k https://kong-admin.armadillo-hamal.ts.net/routes | jq
```

### Kong Proxy
```bash
# Tailscale hostname
kong-kong-kong-proxy.armadillo-hamal.ts.net

# Tailscale IP
100.85.168.121

# Ports: 80 (HTTP), 443 (HTTPS)
```

---

## Common Kubernetes Commands

### Check Kong Status
```bash
# Check pod status
kubectl get pods -n kong

# Check services
kubectl get svc -n kong

# Check ingresses
kubectl get ingress -n kong

# Check ArgoCD application
kubectl get application -n argocd kong
```

### View Logs
```bash
# Kong pod logs
kubectl logs -n kong deployment/kong-kong

# Follow logs
kubectl logs -n kong deployment/kong-kong -f

# Previous logs (if pod crashed)
kubectl logs -n kong deployment/kong-kong --previous
```

### Describe Resources
```bash
# Describe Kong pod
kubectl describe pod -n kong <pod-name>

# Describe Kong service
kubectl describe svc -n kong kong-kong-admin

# Describe Kong ingress
kubectl describe ingress -n kong kong-admin

# Describe ArgoCD application
kubectl describe application -n argocd kong
```

### Execute Commands in Pod
```bash
# Get shell access
kubectl exec -it -n kong deployment/kong-kong -- /bin/sh

# Run Kong command
kubectl exec -n kong deployment/kong-kong -- kong version

# Test PostgreSQL connection
kubectl exec -n kong deployment/kong-kong -- \
  psql -h ameciclo-postgres.privatelink.postgres.database.azure.com \
       -U psqladmin -d kong -c "SELECT version();"
```

---

## Making Changes

### Update Kong Configuration
```bash
# 1. Edit helm-release.yaml
vim azure/kubernetes/kong/helm-release.yaml

# 2. Commit and push
git add azure/kubernetes/kong/helm-release.yaml
git commit -m "Update Kong configuration"
git push

# 3. ArgoCD automatically syncs (watch status)
kubectl get application -n argocd kong -w
```

### Update Ingress
```bash
# 1. Edit ingress file
vim azure/kubernetes/kong/ingress-admin.yaml

# 2. Commit and push
git add azure/kubernetes/kong/ingress-admin.yaml
git commit -m "Update Kong Admin ingress"
git push

# 3. Verify ingress
kubectl get ingress -n kong kong-admin
```

### Update PostgreSQL Credentials
```bash
# 1. Edit secret (base64 encoded)
vim azure/kubernetes/kong/secret.yaml

# 2. Commit and push
git add azure/kubernetes/kong/secret.yaml
git commit -m "Update PostgreSQL credentials"
git push

# 3. Pod will restart with new credentials
kubectl get pods -n kong -w
```

---

## Troubleshooting

### Kong Pod Not Starting
```bash
# Check pod status
kubectl describe pod -n kong <pod-name>

# Check logs
kubectl logs -n kong <pod-name>

# Check events
kubectl get events -n kong --sort-by='.lastTimestamp'
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
kubectl exec -n kong deployment/kong-kong -- \
  psql -h ameciclo-postgres.privatelink.postgres.database.azure.com \
       -U psqladmin -d kong -c "SELECT version();"

# Check Kong logs for connection errors
kubectl logs -n kong deployment/kong-kong | grep -i postgres
```

### ArgoCD Not Syncing
```bash
# Check application status
kubectl describe application -n argocd kong

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller

# Force sync
kubectl patch application -n argocd kong -p '{"metadata":{"annotations":{"argocd.argoproj.io/compare-result":""}}}' --type merge
```

---

## File Locations

### Kong Manifests
```
azure/kubernetes/kong/
├── kustomization.yaml           # Orchestration
├── argocd-application.yaml      # ArgoCD Application
├── namespace.yaml               # Namespace
├── secret.yaml                  # PostgreSQL credentials
├── helm-release.yaml            # Helm chart reference
├── service-admin.yaml           # Admin service
├── ingress-admin.yaml           # Admin ingress
├── ingress-manager.yaml         # Manager ingress
├── values.yaml                  # Helm values (reference)
└── README.md                    # Documentation
```

### Documentation
```
KONG_REDEPLOYMENT_SUMMARY.md    # Deployment summary
KONG_MANIFEST_DEPLOYMENT.md     # Detailed deployment info
KONG_OPERATOR_ANALYSIS.md       # Kong Operator comparison
KONG_QUICK_REFERENCE.md         # This file
```

---

## Useful Links

- Kong Documentation: https://docs.konghq.com/
- Kong Admin API: https://docs.konghq.com/gateway/latest/admin-api/
- Kong Manager: https://docs.konghq.com/gateway/latest/kong-manager/
- ArgoCD Documentation: https://argo-cd.readthedocs.io/
- Kustomize Documentation: https://kustomize.io/
- Tailscale Kubernetes: https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress

---

## Quick Checks

### Is Kong Running?
```bash
kubectl get pods -n kong | grep kong-kong | grep Running
```

### Is Kong Healthy?
```bash
curl -k https://kong-admin.armadillo-hamal.ts.net/status | jq '.database.reachable'
```

### Is PostgreSQL Connected?
```bash
curl -k https://kong-admin.armadillo-hamal.ts.net/status | jq '.database'
```

### Is ArgoCD Synced?
```bash
kubectl get application -n argocd kong | grep Synced
```

### Are Ingresses Working?
```bash
kubectl get ingress -n kong | grep kong-admin
```

---

## Common Tasks

### Create a Kong Service
```bash
curl -X POST https://kong-admin.armadillo-hamal.ts.net/services \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-service",
    "url": "http://example.com"
  }'
```

### Create a Kong Route
```bash
curl -X POST https://kong-admin.armadillo-hamal.ts.net/services/my-service/routes \
  -H "Content-Type: application/json" \
  -d '{
    "paths": ["/api/v1"],
    "methods": ["GET", "POST"]
  }'
```

### Add Kong Plugin
```bash
curl -X POST https://kong-admin.armadillo-hamal.ts.net/services/my-service/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "rate-limiting",
    "config": {
      "minute": 100
    }
  }'
```

### List Kong Plugins
```bash
curl -k https://kong-admin.armadillo-hamal.ts.net/plugins | jq
```

---

## Emergency Commands

### Restart Kong Pod
```bash
kubectl rollout restart deployment/kong-kong -n kong
```

### Force Delete Kong Pod
```bash
kubectl delete pod -n kong <pod-name> --grace-period=0 --force
```

### Restart ArgoCD Sync
```bash
kubectl patch application -n argocd kong -p '{"metadata":{"annotations":{"argocd.argoproj.io/compare-result":""}}}' --type merge
```

### Check All Kong Resources
```bash
kubectl get all -n kong
```

### Get Kong Pod Name
```bash
kubectl get pods -n kong -l app.kubernetes.io/name=kong -o jsonpath='{.items[0].metadata.name}'
```

---

## Tips & Tricks

### Watch Kong Pod Status
```bash
kubectl get pods -n kong -w
```

### Watch ArgoCD Sync
```bash
kubectl get application -n argocd kong -w
```

### Get Kong Pod IP
```bash
kubectl get pods -n kong -l app.kubernetes.io/name=kong -o jsonpath='{.items[0].status.podIP}'
```

### Get Kong Service IPs
```bash
kubectl get svc -n kong -o wide
```

### Port Forward to Kong Admin
```bash
kubectl port-forward -n kong svc/kong-kong-admin 8001:8001
# Then access: http://localhost:8001
```

### Port Forward to Kong Manager
```bash
kubectl port-forward -n kong svc/kong-kong-manager 8002:8002
# Then access: http://localhost:8002
```

---

## Support

For detailed information:
- See `azure/kubernetes/kong/README.md` for complete documentation
- See `KONG_MANIFEST_DEPLOYMENT.md` for deployment details
- Check Kong documentation: https://docs.konghq.com/

