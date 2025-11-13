# Zitadel Configuration for K3s

This directory contains Kubernetes manifests for deploying Zitadel as the Identity and Access Management solution on K3s, managed by ArgoCD.

## Overview

This configuration deploys Zitadel using the official Helm chart via K3s's HelmChart system:
- Deploys Zitadel using the official Helm chart (v9.12.3)
- Exposes Zitadel through Tailscale Ingress
- Supports PostgreSQL database backend
- Includes Login v2 deployment
- Managed entirely through GitOps via ArgoCD

## Files

### `kustomization.yaml`
Kustomize configuration that bundles all Zitadel manifests for ArgoCD deployment.

### `namespace.yaml`
Creates the `zitadel` namespace for all Zitadel resources.

### `zitadel-helm-release.yaml`
K3s HelmChart resource that deploys Zitadel from the official Helm repository with:
- **External Domain**: zitadel.armadillo-hamal.ts.net
- **Database**: PostgreSQL backend
- **Replicas**: 2 for high availability
- **Login v2**: Enabled with 2 replicas
- **Service Type**: ClusterIP (exposed via Tailscale Ingress)

### `zitadel-ingress.yaml`
Tailscale Ingress that exposes Zitadel through your Tailscale network.

## Prerequisites

Before deploying Zitadel, you need to set up the following:

### 1. PostgreSQL Database

Create a `zitadel` database in your existing Azure PostgreSQL server:

```sql
CREATE DATABASE zitadel;
```

The configuration uses the existing `psqladmin` user with the Azure PostgreSQL server at:
`ameciclo-postgres.postgres.database.azure.com`

### 2. Infisical Secrets

Add the following secrets to your Infisical Groundwork project (prod environment):

#### `ZITADEL_DATABASE_PASSWORD`
The password for the `psqladmin` user (same as your existing Azure PostgreSQL password).

#### `ZITADEL_MASTERKEY`
The master key is used for encryption. Generate a secure random key:

```bash
openssl rand -base64 32
```

**IMPORTANT**: Store the master key securely in a password manager or secrets vault. You'll need it for disaster recovery.

### 3. Infisical Machine Identity

The Infisical operator needs to be configured in the `zitadel` namespace. You'll need to create the machine identity secret:

```bash
kubectl create secret generic infisical-machine-identity \
  --namespace zitadel \
  --from-literal=clientId=<your-infisical-client-id> \
  --from-literal=clientSecret=<your-infisical-client-secret>
```

Or use the same machine identity from the `argocd` namespace if it has access to the Groundwork project.

## Accessing Zitadel

### Via Tailscale (Recommended)

Zitadel is accessible at:
```
https://zitadel.armadillo-hamal.ts.net
```

The Login v2 interface is available at:
```
https://zitadel.armadillo-hamal.ts.net/ui/v2/login
```

## Deployment

This configuration is deployed through ArgoCD via the Application manifest at:
```
helm/environments/prod/zitadel-app.yaml
```

ArgoCD automatically syncs these manifests to the cluster.

## Initial Setup

After deployment:

1. Access Zitadel at `https://zitadel.armadillo-hamal.ts.net`
2. Complete the initial setup wizard
3. Create your first organization and project
4. Configure authentication methods (OAuth, OIDC, SAML, etc.)

## Configuration

### Modifying Zitadel Settings

To modify Zitadel configuration:

1. Edit `zitadel-helm-release.yaml` valuesContent section
2. Commit and push to the repository
3. ArgoCD will automatically sync the changes
4. Zitadel will restart with the new configuration

### Database Connection

The configuration connects to your Azure PostgreSQL database at:
- Host: `ameciclo-postgres.postgres.database.azure.com`
- Port: `5432`
- Database: `zitadel`
- User: `psqladmin`
- SSL Mode: `require`

Adjust these settings in `zitadel-helm-release.yaml` if your database configuration differs.

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n zitadel
```

### View Logs
```bash
# Zitadel pods
kubectl logs -n zitadel -l app.kubernetes.io/name=zitadel

# Setup job
kubectl logs -n zitadel -l app.kubernetes.io/component=setup

# Init job
kubectl logs -n zitadel -l app.kubernetes.io/component=init
```

### Database Connection Issues

If Zitadel can't connect to the database:
1. Verify PostgreSQL is running: `kubectl get pods -n zitadel`
2. Check database credentials secret: `kubectl get secret zitadel-db-credentials -n zitadel`
3. Test database connectivity from a debug pod

## Security Considerations

1. **Master Key**: Keep the master key secure and backed up
2. **Database Passwords**: Use strong, randomly generated passwords
3. **TLS**: Tailscale provides encrypted connections
4. **Access Control**: Limit access to the Tailscale network
5. **Backups**: Regularly backup the PostgreSQL database

## Resources

- [Zitadel Documentation](https://zitadel.com/docs)
- [Zitadel Helm Chart](https://github.com/zitadel/zitadel-charts)
- [Zitadel Kubernetes Guide](https://zitadel.com/docs/self-hosting/deploy/kubernetes)

