# Tailscale Connector Deployment Guide

## Overview

This guide explains how to deploy the Tailscale Connector CRD to make your K3s cluster accessible via Tailscale VPN. Once deployed, you can use `kubectl` and `k9s` directly without SSH tunnels.

## What is a Tailscale Connector?

A **Connector** is a Tailscale Kubernetes resource that acts as a **Subnet Router**. It advertises your K3s cluster networks to Tailscale, making them accessible via the VPN.

### Networks Advertised

- **Service CIDR:** `10.43.0.0/16` (Kubernetes services)
- **Pod CIDR:** `10.10.0.0/16` (Kubernetes pods)

Once advertised, you can access:
- K3s API server at `10.10.1.4:6443`
- Any pod or service in the cluster
- All Kubernetes resources directly

## Prerequisites

✅ **Already Done:**
- Tailscale Operator is installed in your K3s cluster
- Tailscale is configured with OAuth credentials
- Your machine is connected to Tailscale VPN

## Deployment Steps

### Step 1: Update Helm Chart Dependencies

```bash
cd helm/charts/tailscale
helm dependency update
```

### Step 2: Deploy via Helm (Manual)

If you want to deploy immediately without waiting for ArgoCD:

```bash
helm upgrade --install tailscale ./helm/charts/tailscale \
  -n tailscale \
  --values helm/values/prod.yaml
```

### Step 3: Verify Connector is Created

```bash
# Check if Connector CRD is created
kubectl get connector -n tailscale

# Expected output:
# NAME                  AGE
# k3s-subnet-router     2m
```

### Step 4: Verify Routes are Advertised

```bash
# Check Tailscale status
tailscale status

# Look for the tailscale-operator entry with AllowedIPs showing:
# - 10.43.0.0/16 (services)
# - 10.10.0.0/16 (pods)
```

Or use JSON output for detailed verification:

```bash
tailscale status --json | jq '.Peer[] | select(.HostName | contains("tailscale")) | {HostName, TailscaleIPs, AllowedIPs}'
```

### Step 5: Test Connectivity

```bash
# Test access to K3s API server
kubectl get nodes

# Test with k9s
k9s

# Test access to a specific pod
kubectl get pods -A
```

## GitOps Deployment (ArgoCD)

To deploy via ArgoCD (recommended for production):

### Create ArgoCD Application

```bash
cat > azure/kubernetes/tailscale/argocd-application.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tailscale
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ameciclo/groundwork
    targetRevision: main
    path: helm/charts/tailscale
    helm:
      valueFiles:
        - ../../../helm/values/prod.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: tailscale
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```

Then apply it:

```bash
kubectl apply -f azure/kubernetes/tailscale/argocd-application.yaml
```

## Troubleshooting

### Issue: Connector not created

```bash
# Check Tailscale Operator logs
kubectl logs -n tailscale -l app.kubernetes.io/name=tailscale-operator -f

# Check if CRD is installed
kubectl get crd | grep connector
```

### Issue: Routes not advertised

```bash
# Check Connector status
kubectl describe connector k3s-subnet-router -n tailscale

# Check Tailscale Operator pod
kubectl get pods -n tailscale
kubectl logs -n tailscale -l app.kubernetes.io/name=tailscale-operator
```

### Issue: Still can't access cluster via Tailscale

1. Verify you're connected to Tailscale VPN:
   ```bash
   tailscale status
   ```

2. Verify routes are advertised:
   ```bash
   tailscale status --json | jq '.Peer[] | select(.HostName | contains("tailscale")) | .AllowedIPs'
   ```

3. Test connectivity to the network:
   ```bash
   ping 10.10.1.4
   ```

4. If ping works but kubectl doesn't, check kubeconfig:
   ```bash
   kubectl config view | grep server
   ```

## Configuration

### Custom Routes

To advertise additional routes, edit `helm/charts/tailscale/values.yaml`:

```yaml
connector:
  enabled: true
  serviceCIDR: "10.43.0.0/16"
  podCIDR: "10.10.0.0/16"
  # Add more routes if needed:
  # routes:
  #   - "192.168.0.0/16"
  #   - "172.16.0.0/12"
```

### Custom Hostname

Change the subnet router hostname:

```yaml
connector:
  hostname: "my-k3s-router"
```

## Next Steps

Once the Connector is deployed and routes are advertised:

1. ✅ Access K3s cluster via Tailscale VPN
2. ✅ Use `kubectl` and `k9s` without SSH tunnels
3. ✅ Deploy applications via ArgoCD
4. ✅ Access services via Tailscale Ingress

## References

- [Tailscale Operator Documentation](https://tailscale.com/kb/1236/kubernetes-operator)
- [Tailscale Connector CRD](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)
- [K3s Networking](https://docs.k3s.io/networking)

