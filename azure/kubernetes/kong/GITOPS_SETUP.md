# Kong GitOps + Manager (Read-Only) Setup

## Architecture Overview

This setup provides:
- **Kong in DB-less mode** - All configuration from YAML files (GitOps)
- **Kong Manager UI** - Read-only mode for visualization
- **Kong Admin API** - For programmatic access
- **Git as source of truth** - All routes/services in version control

## Components

### 1. Kong Deployment (`deployment.yaml`)
- **Image**: `kong:3.4` (DB-less)
- **Database**: OFF (declarative config only)
- **Ports**:
  - `8000`: HTTP proxy
  - `8443`: HTTPS proxy
  - `8001`: Admin API
  - `8002`: Manager UI
- **Read-Only Mode**: `KONG_ADMIN_GUI_READ_ONLY=on`

### 2. Services (`service.yaml`)
- **kong-proxy**: LoadBalancer (ports 80/443) - Public-facing
- **kong-admin**: ClusterIP (port 8001) - Internal only
- **kong-manager**: ClusterIP (port 8002) - Internal only

### 3. Ingress (`ingress.yaml`)
- **kong-manager**: Tailscale ingress at `kong-manager.armadillo-hamal.ts.net`
- **kong-admin**: Tailscale ingress at `kong-admin.armadillo-hamal.ts.net`

### 4. Configuration (`deployment.yaml` ConfigMap)
- **kong.yaml**: Declarative Kong configuration
- Format: Kong 3.0+ YAML format

## How GitOps Works

1. **Define routes in YAML**:
   ```yaml
   services:
     - name: my-service
       url: http://my-service:8080
       routes:
         - name: my-route
           paths:
             - /api/v1
   ```

2. **Commit to Git**:
   ```bash
   git add azure/kubernetes/kong/deployment.yaml
   git commit -m "Add new route"
   git push
   ```

3. **ArgoCD deploys automatically**:
   - ArgoCD detects changes
   - Updates ConfigMap
   - Kong reloads configuration

4. **Kong Manager shows read-only view**:
   - Access at: `http://kong-manager.armadillo-hamal.ts.net`
   - View all routes, services, plugins
   - Cannot modify (read-only mode)

## Adding Routes

Edit the ConfigMap in `deployment.yaml`:

```yaml
data:
  kong.yaml: |
    _format_version: "3.0"
    services:
      - name: example-api
        url: http://example-api-service:8080
        routes:
          - name: example-route
            paths:
              - /api/example
            methods:
              - GET
              - POST
    routes: []
```

## Accessing Kong

### Kong Proxy (Public)
- **HTTP**: `http://<AZURE_VM_PUBLIC_IP>:80`
- **HTTPS**: `https://<AZURE_VM_PUBLIC_IP>:443`

### Kong Manager (Tailscale)
- **URL**: `http://kong-manager.armadillo-hamal.ts.net`
- **Access**: Via Tailscale VPN only
- **Mode**: Read-only

### Kong Admin API (Tailscale)
- **URL**: `http://kong-admin.armadillo-hamal.ts.net`
- **Access**: Via Tailscale VPN only
- **Use**: For monitoring/debugging

## Key Features

✅ **GitOps**: All config in Git, version controlled
✅ **No Database**: DB-less mode, simpler deployment
✅ **Read-Only Manager**: Safe UI for visualization
✅ **Tailscale Protected**: Admin/Manager behind VPN
✅ **Public Proxy**: Kong proxy accessible from internet
✅ **Auto-Reload**: Kong reloads on ConfigMap changes

## Troubleshooting

### Kong not reloading config
```bash
kubectl rollout restart deployment/kong -n kong
```

### Check Kong status
```bash
kubectl exec -n kong deployment/kong -- kong version
```

### View Kong logs
```bash
kubectl logs -n kong deployment/kong
```

### Test Kong Admin API
```bash
kubectl port-forward -n kong svc/kong-admin 8001:8001
curl http://localhost:8001/status
```

## Next Steps

1. Add your first route to `deployment.yaml`
2. Commit and push to Git
3. ArgoCD will deploy automatically
4. Access Kong Manager to verify
5. Test your route via Kong proxy

