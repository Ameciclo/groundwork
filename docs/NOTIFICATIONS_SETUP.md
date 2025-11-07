# ArgoCD Notifications Setup

## Overview

This document describes how Telegram notifications are configured for ArgoCD deployments using ArgoCD's built-in secret management.

## Architecture

```
ArgoCD Application Event
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

### 1. Secret Storage (argocd-notifications-secret)

Telegram credentials are stored in a Kubernetes Secret:

```bash
kubectl create secret generic argocd-notifications-secret \
  --from-literal=telegram-token="YOUR_BOT_TOKEN" \
  --from-literal=telegram-chatid="YOUR_CHAT_ID" \
  -n argocd
```

### 2. ConfigMap Reference (argocd-notifications-cm)

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

✅ Secrets stored in Kubernetes Secret resource  
✅ No hardcoded values in ConfigMap  
✅ No secrets in git repository  
✅ Credentials encrypted at rest in etcd  

## Troubleshooting

Check logs:
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller
```

Verify secret exists:
```bash
kubectl get secret argocd-notifications-secret -n argocd
```

Verify ConfigMap:
```bash
kubectl get configmap argocd-notifications-cm -n argocd -o yaml
```

## References

- [ArgoCD Notifications Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/)
- [Notification Services Overview](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/overview/)

