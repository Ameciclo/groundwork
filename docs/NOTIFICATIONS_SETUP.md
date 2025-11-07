# ArgoCD Notifications Setup

## Overview

This document describes how Telegram notifications are configured for ArgoCD deployments using the Infisical Operator for secure secret management.

## Architecture

```
Infisical Cloud (groundwork project)
    ↓
Infisical Operator (InfisicalSecret CRD)
    ↓
Kubernetes Secret: argocd-notifications-secret
    ↓
ArgoCD Notifications Controller
    ↓
Reads ConfigMap: argocd-notifications-cm
    ↓
References Secret: argocd-notifications-secret
    ↓
Sends Telegram Message
```

## Configuration

### 1. Infisical Setup

Telegram credentials are stored in Infisical groundwork project:
- **Project ID**: `2c6394a4-3352-49f1-86fb-634249e3c7cb`
- **Environment**: `prod`
- **Secrets**:
  - `TELEGRAM_BOT_TOKEN`: Your Telegram bot token
  - `TELEGRAM_CHAT_ID`: Your Telegram chat ID

### 2. Infisical Operator (InfisicalSecret CRD)

The InfisicalSecret CRD syncs secrets from Infisical to Kubernetes:

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: argocd-notifications-telegram
  namespace: argocd
spec:
  hostAPI: https://app.infisical.com/api
  resyncInterval: 60
  authentication:
    universalAuth:
      credentialsRef:
        secretName: infisical-machine-identity
        secretNamespace: argocd
      secretsScope:
        projectId: "2c6394a4-3352-49f1-86fb-634249e3c7cb"
        envSlug: "prod"
        secretsPath: "/"
  managedKubeSecretReferences:
    - secretName: argocd-notifications-secret
      secretNamespace: argocd
      creationPolicy: "Owner"
      template:
        includeAllSecrets: true
```

### 3. ConfigMap Reference (argocd-notifications-cm)

The ConfigMap references secrets using `$key` syntax:

```yaml
service.telegram: |
  token: $telegram-token
  chatID: $telegram-chatid
```

### 3. Application Subscriptions

Applications are configured to send notifications:

```yaml
metadata:
  annotations:
    notifications.argoproj.io/subscribe.on-deployed.telegram: "-1001485248506"
    notifications.argoproj.io/subscribe.on-sync-failed.telegram: "-1001485248506"
    notifications.argoproj.io/subscribe.on-health-degraded.telegram: "-1001485248506"
```

## Notification Triggers

- **on-deployed**: When application successfully deploys
- **on-sync-failed**: When sync operation fails
- **on-health-degraded**: When application health degrades

## Security

✅ Secrets stored in Infisical (centralized secret management)
✅ Automatically synced to Kubernetes Secret by Infisical Operator
✅ No hardcoded values in ConfigMap or git
✅ Credentials encrypted in transit and at rest
✅ Audit trail in Infisical for all secret access
✅ Easy secret rotation - update in Infisical, automatically synced
✅ Resync interval: 60 seconds (configurable)

## Troubleshooting

### Check Infisical Operator Status

```bash
# Verify InfisicalSecret is syncing
kubectl get infisicalsecrets -n argocd
kubectl describe infisicalsecret argocd-notifications-telegram -n argocd

# Check Infisical Operator logs
kubectl logs -n infisical-operator-system -l app.kubernetes.io/name=secrets-operator
```

### Check ArgoCD Notifications

```bash
# Check notification controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller

# Verify secret exists and has correct keys
kubectl get secret argocd-notifications-secret -n argocd -o yaml

# Verify ConfigMap
kubectl get configmap argocd-notifications-cm -n argocd -o yaml
```

### Common Issues

**Secret not syncing from Infisical:**
- Verify `infisical-machine-identity` secret exists in argocd namespace
- Check Infisical Operator logs for authentication errors
- Ensure machine identity has access to groundwork project

**Notifications not sending:**
- Check ArgoCD Notifications Controller logs for errors
- Verify `argocd-notifications-secret` has `telegram-token` and `telegram-chatid` keys
- Ensure ConfigMap references correct secret keys

## References

- [Infisical Kubernetes Operator](https://infisical.com/docs/integrations/platforms/kubernetes)
- [InfisicalSecret CRD Documentation](https://infisical.com/docs/integrations/platforms/kubernetes/infisical-secret-crd)
- [ArgoCD Notifications Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/)
- [Notification Services Overview](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/overview/)

