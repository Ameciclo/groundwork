# Infisical Secrets Management

Centralized secrets management using Infisical with GitOps.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        infisical-system namespace                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────────────┐    ┌─────────────────────────┐           │
│   │ infisical-universal-    │    │ Infisical Operator      │           │
│   │ auth (Secret)           │    │ (Deployment)            │           │
│   │                         │    │                         │           │
│   │ Created by: Ansible     │    │ Created by: ArgoCD      │           │
│   │ Contains: clientId,     │    │ (Helm chart)            │           │
│   │           clientSecret  │    │                         │           │
│   └───────────┬─────────────┘    └─────────────────────────┘           │
│               │                                                         │
└───────────────┼─────────────────────────────────────────────────────────┘
                │
                │ Referenced by ALL InfisicalSecret CRDs (cross-namespace)
                │
    ┌───────────┼───────────┬───────────────────┐
    ▼           ▼           ▼                   ▼
┌───────┐  ┌────────┐  ┌─────────┐        ┌──────────┐
│strapi │  │ argocd │  │  atlas  │  ...   │ future   │
│secrets│  │secrets │  │ secrets │        │   app    │
└───────┘  └────────┘  └─────────┘        └──────────┘
```

## How It Works

1. **Bootstrap (Ansible)**: Creates `infisical-system` namespace and auth secret
2. **GitOps (ArgoCD)**: Manages the Infisical operator via Helm chart
3. **GitOps (ArgoCD)**: Syncs InfisicalSecret CRDs from this directory
4. **Operator**: Watches CRDs and syncs secrets from Infisical to K8s

## Files

| File | Purpose | Managed By |
|------|---------|------------|
| `namespace.yaml` | Creates infisical-system namespace | ArgoCD |
| `strapi-infisical-secret.yaml` | Syncs Strapi secrets | ArgoCD |
| `README.md` | Documentation | - |

## Adding a New Application

### 1. Create Infisical Project

1. Login to [Infisical](https://app.infisical.com)
2. Create a new project (or use existing)
3. Add secrets to the appropriate environment (dev/staging/prod)
4. Note the **Project Slug** from Project Settings
5. Grant your Machine Identity access to the project

### 2. Create InfisicalSecret CRD

Create a new file in this directory (e.g., `myapp-infisical-secret.yaml`):

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: myapp-secrets
  namespace: myapp  # Your app's namespace
  labels:
    app.kubernetes.io/name: myapp
spec:
  hostAPI: https://app.infisical.com/api
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: myapp-project-slug  # From Infisical
        envSlug: prod
        secretsPath: "/"
      credentialsRef:
        secretName: infisical-universal-auth
        secretNamespace: infisical-system  # Always use central namespace
  managedSecretReference:
    secretName: myapp-managed-secrets  # K8s secret to create
    secretNamespace: myapp
    creationPolicy: Owner
  resyncInterval: 60
```

### 3. Commit and Push

```bash
git add kubernetes/infrastructure/infisical/myapp-infisical-secret.yaml
git commit -m "feat: add Infisical secrets for myapp"
git push
```

ArgoCD will automatically sync the new CRD.

### 4. Reference in Deployment

```yaml
# In your deployment
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: myapp-managed-secrets
        key: DATABASE_URL
```

## Bootstrap (First-Time Setup)

The auth secret is created by Ansible during cluster bootstrap:

```bash
# Set environment variables
export TAILSCALE_OAUTH_CLIENT_ID=xxx
export TAILSCALE_OAUTH_CLIENT_SECRET=xxx
export INFISICAL_CLIENT_ID=xxx        # From Infisical Machine Identity
export INFISICAL_CLIENT_SECRET=xxx    # From Infisical Universal Auth

# Run playbook
cd automation/ansible
ansible-playbook -i inventory.ini k3s-bootstrap-playbook.yml
```

## Credential Rotation

To rotate the Infisical credentials:

1. Create new Client Secret in Infisical Machine Identity
2. Update the secret on the cluster:
   ```bash
   kubectl create secret generic infisical-universal-auth \
     --namespace=infisical-system \
     --from-literal=clientId=NEW_CLIENT_ID \
     --from-literal=clientSecret=NEW_CLIENT_SECRET \
     --dry-run=client -o yaml | kubectl apply -f -
   ```
3. Restart the operator (optional, it will pick up changes):
   ```bash
   kubectl rollout restart deployment -n infisical-system -l app.kubernetes.io/name=secrets-operator
   ```

## Troubleshooting

### Check Operator Status
```bash
kubectl get pods -n infisical-system
kubectl logs -n infisical-system -l app.kubernetes.io/name=secrets-operator
```

### Check InfisicalSecret Status
```bash
kubectl describe infisicalsecret <name> -n <namespace>
```

### Verify Secrets Synced
```bash
kubectl get secret <managed-secret-name> -n <namespace> -o yaml
```

## Current Integrations

| Application | Infisical Project | K8s Secret | Namespace |
|-------------|-------------------|------------|-----------|
| Strapi | `strapi-he-ce` | `strapi-infisical-managed` | strapi |

## Related ArgoCD Applications

- `infisical-operator` - Helm chart for the operator
- `infisical-config` - This directory (CRDs and namespace)
