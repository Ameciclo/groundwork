# Tailscale Operator Helm Chart

A Helm chart for deploying the Tailscale Operator on Kubernetes, enabling VPN access to cluster services.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- Tailscale account (free tier available)
- Tailscale auth key

## Getting Tailscale Auth Key

1. Go to https://login.tailscale.com/admin/settings/keys
2. Create a new auth key (reusable, with expiration)
3. Copy the key

## Installation

### 1. Create a secret with your Tailscale auth key

```bash
kubectl create secret generic tailscale-auth \
  --from-literal=key=<your-auth-key> \
  -n tailscale
```

### 2. Create values file

Create `tailscale-values.yaml`:

```yaml
tailscale-operator:
  replicaCount: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi

tailscale:
  mode: "operator"
```

### 3. Install the chart

```bash
helm install tailscale ./tailscale -n tailscale --create-namespace \
  -f tailscale-values.yaml
```

### 4. Verify installation

```bash
kubectl get pods -n tailscale
kubectl logs -n tailscale -l app.kubernetes.io/name=tailscale-operator
```

## Configuration

### Operator Mode (Default)

Allows you to expose Kubernetes services via Tailscale:

```yaml
tailscale:
  mode: "operator"
```

Then annotate services to expose them:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    tailscale.com/expose: "true"
spec:
  # ... service spec
```

### Proxy Mode (Subnet Router)

Make your network accessible via Tailscale:

```yaml
tailscale:
  proxyMode: true
  proxy:
    routes:
      - 10.0.0.0/8
      - 192.168.0.0/16
    hostname: k3s-proxy
    tags:
      - tag:k8s-proxy
```

## Exposing Services

### Via Service Annotation

```yaml
apiVersion: v1
kind: Service
metadata:
  name: argocd
  namespace: argocd
  annotations:
    tailscale.com/expose: "true"
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: argocd
```

### Access from Tailscale

Once exposed, access the service from any Tailscale node:

```bash
# Get the Tailscale IP
tailscale ip -4

# Access the service
curl http://argocd.k3s-cluster.ts.net
```

## Troubleshooting

### Check operator logs

```bash
kubectl logs -n tailscale -l app.kubernetes.io/name=tailscale-operator
```

### Verify auth key

```bash
kubectl get secret -n tailscale tailscale-auth -o jsonpath='{.data.key}' | base64 -d
```

### Check exposed services

```bash
kubectl get svc -A -o jsonpath='{range .items[?(@.metadata.annotations.tailscale\.com/expose=="true")]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'
```

### Verify Tailscale connection

```bash
# From a Tailscale node
tailscale status
```

## Resource Requirements

Default resources are minimal:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

Adjust based on your cluster size and number of exposed services.

## Security

- Operator runs as non-root user
- Read-only root filesystem
- No privilege escalation
- Minimal capabilities

## Uninstall

```bash
helm uninstall tailscale -n tailscale
```

## References

- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator/)
- [Tailscale Helm Charts](https://pkgs.tailscale.com/helmcharts)

