# Traefik Configuration

This directory contains Kubernetes manifests for Traefik ingress controller configuration on the k3s cluster, managed by ArgoCD.

## Files

- **service.yaml** - NodePort service to expose Traefik externally
  - HTTP: Port 32746 (maps to 8000)
  - HTTPS: Port 30629 (maps to 8443)
  - Dashboard: Port 30813 (maps to 8080)

- **tailscale-ingress.yaml** - Tailscale Ingress to expose the Traefik web interface
  - Accessible at `https://traefik-1.armadillo-hamal.ts.net/` via Tailscale
  - Uses Tailscale ingress controller with TLS and Let's Encrypt certificates

- **kustomization.yaml** - Kustomize configuration for ArgoCD deployment

- **values.yaml** - Helm values for Traefik configuration

## Deployment

This is deployed through ArgoCD via the Application manifest at `helm/environments/prod/traefik-app.yaml`.

ArgoCD automatically syncs these manifests to the cluster.

## Accessing the Dashboard

### Via Tailscale Ingress (Recommended)

Access: `https://traefik.armadillo-hamal.ts.net/dashboard/`

The Tailscale ingress controller automatically:
- Exposes the service on your Tailscale network
- Provides TLS encryption with Let's Encrypt certificates
- Routes traffic to the Traefik web interface
- Note: The `-1` suffix is added by Tailscale when using hostname `traefik`

### Via Traefik IngressRoute (Alternative)

The dashboard is also exposed via Traefik's IngressRoute at:
- HTTP: `http://10.10.1.4:32746/` (through Tailscale subnet)
- HTTPS: `https://10.10.1.4:30629/` (through Tailscale subnet)

Use the Host header: `Host: traefik.armadillo-hamal.ts.net`

## Entry Points

- **web** (HTTP): Port 8000 → NodePort 32746
- **websecure** (HTTPS): Port 8443 → NodePort 30629
- **traefik** (Dashboard): Port 8080 → NodePort 30813
- **metrics** (Prometheus): Port 9100

## Architecture

```
Tailscale Network
    ↓
Tailscale Ingress Controller
    ↓
traefik-dashboard Ingress (ingressClassName: tailscale)
    ↓
traefik Service (kube-system)
    ↓
Traefik Pod (Dashboard on port 8080)
```

## Notes

- Traefik is installed via k3s HelmChart system
- Dashboard is exposed via Tailscale Ingress (not Traefik IngressRoute)
- TLS is automatically managed by Tailscale ingress controller
- Prometheus metrics are available on port 9100
- All configuration is managed by ArgoCD for GitOps workflow

