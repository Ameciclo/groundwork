# Zitadel Setup Guide

Quick setup guide for deploying Zitadel to your K3s cluster.

## Step 1: Create the Zitadel Database

Connect to your Azure PostgreSQL server and create the database:

```sql
CREATE DATABASE zitadel;
```

You can use the Azure Portal, Azure CLI, or connect directly with `psql`:

```bash
psql "host=ameciclo-postgres.postgres.database.azure.com port=5432 dbname=postgres user=psqladmin sslmode=require"
```

## Step 2: Add Secrets to Infisical

In your Infisical Groundwork project (prod environment), add these two secrets:

### `ZITADEL_DATABASE_PASSWORD`
```
YourSecurePassword123!
```
(Use the same password as your `psqladmin` user)

### `ZITADEL_MASTERKEY`
Generate a new master key:
```bash
openssl rand -base64 32
```

Example output: `xK8vN2mP9qR4sT6uV7wX8yZ0aB1cD2eF3gH4iJ5kL6m=`

**IMPORTANT**: Save this master key somewhere secure (password manager). You'll need it for disaster recovery!

## Step 3: Create Infisical Machine Identity Secret

The `zitadel` namespace needs access to Infisical. Create the machine identity secret:

```bash
# Option 1: Copy from argocd namespace (if using the same machine identity)
kubectl get secret infisical-machine-identity -n argocd -o yaml | \
  sed 's/namespace: argocd/namespace: zitadel/' | \
  kubectl apply -f -

# Option 2: Create a new one
kubectl create secret generic infisical-machine-identity \
  --namespace zitadel \
  --from-literal=clientId=<your-infisical-client-id> \
  --from-literal=clientSecret=<your-infisical-client-secret>
```

## Step 4: Deploy via ArgoCD

Commit and push the changes to your repository:

```bash
git add helm/charts/zitadel/ helm/environments/prod/zitadel-app.yaml
git commit -m "Add Zitadel identity and access management"
git push
```

ArgoCD will automatically:
1. Create the `zitadel` namespace
2. Sync secrets from Infisical
3. Deploy Zitadel with 2 replicas
4. Deploy Login v2 with 2 replicas
5. Create the Tailscale ingress

## Step 5: Access Zitadel

Once deployed, access Zitadel at:

```
https://zitadel.armadillo-hamal.ts.net
```

## Step 6: Initial Setup

1. Complete the initial setup wizard
2. Create your first organization
3. Set up your first project
4. Configure authentication methods

## Troubleshooting

### Check deployment status
```bash
kubectl get pods -n zitadel
kubectl get ingress -n zitadel
```

### View logs
```bash
# Zitadel pods
kubectl logs -n zitadel -l app.kubernetes.io/name=zitadel --tail=100

# Setup job
kubectl logs -n zitadel -l app.kubernetes.io/component=setup --tail=100
```

### Check secrets
```bash
# Verify Infisical synced the secrets
kubectl get secret zitadel-infisical-managed -n zitadel
kubectl get secret zitadel-masterkey -n zitadel
```

### Database connection issues
```bash
# Test connection from a debug pod
kubectl run -it --rm debug --image=postgres:16 --restart=Never -n zitadel -- \
  psql "host=ameciclo-postgres.postgres.database.azure.com port=5432 dbname=zitadel user=psqladmin sslmode=require"
```

## Summary

You now have:
- ✅ Zitadel running with 2 replicas for high availability
- ✅ Login v2 interface enabled
- ✅ Secure database connection to Azure PostgreSQL
- ✅ Secrets managed via Infisical
- ✅ Accessible via Tailscale at `https://zitadel.armadillo-hamal.ts.net`
- ✅ Automatic sync and healing via ArgoCD

