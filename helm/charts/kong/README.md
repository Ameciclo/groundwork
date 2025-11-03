# Kong API Gateway Helm Chart

A Helm chart for deploying Kong API Gateway on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- PostgreSQL database (external or managed)

## Installation

### 1. Add the chart repository (if using external repo)

```bash
helm repo add kong https://charts.konghq.com
helm repo update
```

### 2. Create a values file with your configuration

Create `kong-values.yaml`:

```yaml
kong:
  pg:
    host: your-postgres-host.example.com
    port: 5432
    user: kong
    database: kong
    password: your-secure-password
    ssl: "on"
  
  adminGui:
    sessionSecret: your-session-secret

service:
  type: LoadBalancer
  # or use ClusterIP with Ingress
```

### 3. Install the chart

```bash
helm install kong ./kong -n kong --create-namespace -f kong-values.yaml
```

### 4. Verify the installation

```bash
kubectl get pods -n kong
kubectl get svc -n kong
```

## Configuration

### Kong Database

Configure PostgreSQL connection details:

```yaml
kong:
  pg:
    host: postgres.example.com
    port: 5432
    user: kong
    database: kong
    password: secure-password
    ssl: "on"
```

### Kong Manager (Admin GUI)

Enable and configure Kong Manager:

```yaml
kong:
  adminGui:
    listen: "0.0.0.0:8002"
    auth: "basic-auth"
    sessionSecret: your-secret-key
```

### Service Exposure

Choose how to expose Kong:

**LoadBalancer:**
```yaml
service:
  type: LoadBalancer
```

**Ingress:**
```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: kong.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Resource Limits

Configure resource requests and limits:

```yaml
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Scaling

Enable horizontal pod autoscaling:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

## Accessing Kong

### Admin API

```bash
kubectl port-forward -n kong svc/kong 8001:8001
curl http://localhost:8001/status
```

### Kong Manager (Admin GUI)

```bash
kubectl port-forward -n kong svc/kong 8002:8002
# Access at http://localhost:8002
```

### Proxy

If using LoadBalancer:

```bash
kubectl get svc -n kong
# Use the EXTERNAL-IP for proxy requests
```

## Troubleshooting

### Check pod logs

```bash
kubectl logs -n kong -l app.kubernetes.io/name=kong
```

### Verify database connection

```bash
kubectl exec -it -n kong <pod-name> -- kong health
```

### Check secrets

```bash
kubectl get secrets -n kong
kubectl describe secret -n kong kong-db
```

## Uninstall

```bash
helm uninstall kong -n kong
```

## Values Reference

See `values.yaml` for all available configuration options.

