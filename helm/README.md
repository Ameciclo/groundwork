# Helm Charts for k3s Cluster

This directory contains Helm charts for deploying applications to the k3s cluster.

## Directory Structure

```
helm/
├── charts/              # Individual Helm charts
├── values/              # Production values overrides
└── environments/        # ArgoCD ApplicationSet definitions
    └── prod/
```

## Charts

- **tailscale**: Tailscale VPN operator for secure cluster networking

## Deployment

### Prerequisites

- k3s cluster running
- Helm 3.x installed
- kubectl configured to access the cluster

### Deploy a Chart

```bash
# Deploy with default values
helm install tailscale ./charts/tailscale -n tailscale --create-namespace

# Deploy with production values
helm install tailscale ./charts/tailscale -n tailscale --create-namespace \
  -f values/prod.yaml
```

### Update Dependencies

```bash
cd charts/tailscale
helm dependency update
```

## Production Values

Production-specific value overrides are in `values/prod.yaml`.

## ArgoCD Integration

ApplicationSet definitions are located in `environments/prod/` for GitOps-based deployments.

## Adding New Charts

1. Create a new chart: `helm create charts/my-chart`
2. Add dependencies if needed in `Chart.yaml`
3. Run `helm dependency update` in the chart directory
4. Create environment-specific values in `values/`
5. Add ApplicationSet definitions in `environments/`

