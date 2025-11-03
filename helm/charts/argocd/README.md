# ArgoCD Helm Chart

A Helm chart for deploying ArgoCD (GitOps Continuous Deployment) on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- Git repository for GitOps

## Installation

### 1. Create a values file with your configuration

Create `argocd-values.yaml`:

```yaml
argocd:
  adminPassword: "your-secure-password"
  
  repositories:
    - url: https://github.com/your-org/your-repo.git
      type: git
      username: your-username
      password: your-token

service:
  type: ClusterIP
  # For Tailscale exposure, add annotation:
  annotations:
    tailscale.com/expose: "true"
```

### 2. Install the chart

```bash
helm install argocd ./argocd -n argocd --create-namespace -f argocd-values.yaml
```

### 3. Verify the installation

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

## Configuration

### Admin Password

Set the admin password for ArgoCD:

```yaml
argocd:
  adminPassword: "your-secure-password"
```

Or use a secret:

```bash
kubectl create secret generic argocd-admin \
  --from-literal=password=your-password \
  -n argocd
```

### Repository Configuration

Add Git repositories for ArgoCD to sync:

```yaml
argocd:
  repositories:
    - url: https://github.com/your-org/your-repo.git
      type: git
      username: your-username
      password: your-token
```

### Service Exposure

**ClusterIP (default):**
```yaml
service:
  type: ClusterIP
```

**Tailscale Exposure:**
```yaml
service:
  type: ClusterIP
  annotations:
    tailscale.com/expose: "true"
```

**Ingress:**
```yaml
argocd:
  server:
    ingress:
      enabled: true
      className: nginx
      hosts:
        - host: argocd.example.com
          paths:
            - path: /
              pathType: Prefix
```

### Resource Configuration

Adjust resources for different components:

```yaml
argocd:
  applicationController:
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
  
  repoServer:
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
  
  server:
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

## Accessing ArgoCD

### Port Forward

```bash
kubectl port-forward -n argocd svc/argocd 8080:80
# Access at http://localhost:8080
```

### Get Initial Admin Password

```bash
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Login with ArgoCD CLI

```bash
argocd login localhost:8080 --username admin --password <password>
```

## Creating Applications

### Via CLI

```bash
argocd app create my-app \
  --repo https://github.com/your-org/your-repo.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

### Via GitOps (Application CRD)

Create an Application manifest in your Git repository:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo.git
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Troubleshooting

### Check pod logs

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd
```

### Verify repository connection

```bash
kubectl exec -it -n argocd <pod-name> -- argocd repo list
```

### Check application status

```bash
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
```

## Uninstall

```bash
helm uninstall argocd -n argocd
```

## Values Reference

See `values.yaml` for all available configuration options.

