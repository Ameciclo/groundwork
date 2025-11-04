# Traefik Configuration for K3s

This directory contains Kubernetes manifests for configuring the native Traefik ingress controller that comes with K3s, managed by ArgoCD.

## Overview

K3s comes with Traefik pre-installed by default. This configuration:
- Configures the native Traefik instance via ConfigMap
- Exposes the Traefik dashboard through Tailscale Ingress
- Enables Prometheus metrics
- Supports both Kubernetes CRDs and standard Ingress resources

## Files

### `kustomization.yaml`
Kustomize configuration that bundles all Traefik manifests for ArgoCD deployment.

### `traefik-config.yaml`
ConfigMap that configures the native Traefik instance with:
- **Entry Points**: web (8000), websecure (8443), traefik (8080), metrics (9100)
- **API & Dashboard**: Enabled on port 8080
- **Providers**: Kubernetes CRDs and standard Ingress resources
- **Metrics**: Prometheus metrics on port 9100
- **Logging**: JSON format for structured logging

### `traefik-dashboard-ingress.yaml`
Tailscale Ingress that exposes the Traefik dashboard through your Tailscale network.

## Accessing the Dashboard

### Via Tailscale (Recommended)

The dashboard is accessible at:
```
https://traefik.armadillo-hamal.ts.net
```

This uses the Tailscale Ingress controller to expose the dashboard securely through your Tailscale network.

**Requirements:**
- Tailscale Operator must be installed on the cluster
- Your machine must be connected to the same Tailscale network
- Run: `sudo tailscale up --accept-routes` to accept cluster routes

### Via Direct IP (Alternative)

If you need direct access through the cluster IP:
```
http://10.10.1.4:8080
```

## Entry Points

| Name | Port | Purpose |
|------|------|---------|
| web | 8000 | HTTP traffic |
| websecure | 8443 | HTTPS traffic |
| traefik | 8080 | Dashboard and API |
| metrics | 9100 | Prometheus metrics |

## Deployment

This configuration is deployed through ArgoCD via the Application manifest at:
```
helm/environments/prod/traefik-app.yaml
```

ArgoCD automatically syncs these manifests to the cluster.

## Configuration

### Modifying Traefik Settings

To modify Traefik configuration:

1. Edit `traefik-config.yaml` ConfigMap
2. Commit and push to the repository
3. ArgoCD will automatically sync the changes
4. Traefik will reload the configuration

### Adding Routes

You can expose services through Traefik using:

**Standard Kubernetes Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-service
spec:
  ingressClassName: traefik
  rules:
    - host: my-service.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

**Traefik CRD (IngressRoute):**
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-service
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`my-service.example.com`)
      kind: Rule
      services:
        - name: my-service
          port: 80
```

## Metrics

Prometheus metrics are available on port 9100. You can scrape metrics from:
```
http://traefik:9100/metrics
```

## Troubleshooting

### Dashboard not accessible via Tailscale

1. Verify Tailscale Operator is running:
   ```bash
   kubectl get pods -n tailscale
   ```

2. Check Ingress status:
   ```bash
   kubectl get ingress -n kube-system traefik-dashboard
   ```

3. Check Traefik pod logs:
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
   ```

### Traefik not routing traffic

1. Verify Traefik is running:
   ```bash
   kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik
   ```

2. Check Ingress resources:
   ```bash
   kubectl get ingress -A
   ```

3. Check Traefik logs:
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik -f
   ```

## References

- [K3s Traefik Documentation](https://docs.k3s.io/networking/traefik)
- [Traefik Documentation](https://doc.traefik.io/)
- [Tailscale Kubernetes Ingress](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)
