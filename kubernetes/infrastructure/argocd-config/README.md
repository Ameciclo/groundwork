# ArgoCD Configuration

This chart manages ArgoCD's own configuration resources via GitOps.

## Overview

This directory contains configuration resources for ArgoCD itself, managed through GitOps:
- ArgoCD Notifications ConfigMap with Telegram integration
- Infisical Secret sync for notification credentials

By managing these resources through ArgoCD, we achieve:
- ✅ **GitOps for ArgoCD configuration** - All changes tracked in Git
- ✅ **Automatic sync** - No manual `kubectl apply` needed
- ✅ **Visibility** - Configuration visible in ArgoCD UI
- ✅ **Self-healing** - ArgoCD restores configuration if modified
- ✅ **Consistency** - Everything managed the same way

## Files

### `kustomization.yaml`
Kustomize configuration that bundles all ArgoCD config manifests.

### `argocd-notifications-cm.yaml`
ConfigMap containing:
- Telegram service configuration
- Notification templates (deployed, failed, degraded, etc.)
- Notification triggers
- Subscription configuration

### `argocd-infisical-secretstore.yaml`
InfisicalSecret CRD that syncs secrets from Infisical to Kubernetes:
- Syncs `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` from Infisical
- Creates `argocd-notifications-secret` in the argocd namespace
- Resync interval: 60 seconds

## Deployment

This configuration is deployed through ArgoCD via the Application manifest at:
```
helm/environments/prod/argocd-config-app.yaml
```

ArgoCD automatically syncs these manifests to the cluster.

## Modifying Notification Templates

To modify notification templates:

1. Edit `argocd-notifications-cm.yaml`
2. Commit and push to the repository
3. ArgoCD will automatically sync the changes
4. The notifications controller will reload the configuration

## Modifying Secret Sync

To modify the Infisical secret sync:

1. Edit `argocd-infisical-secretstore.yaml`
2. Commit and push to the repository
3. ArgoCD will automatically sync the changes
4. The Infisical operator will update the secret

## References

- [ArgoCD Notifications Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/)
- [Infisical Kubernetes Operator](https://infisical.com/docs/integrations/platforms/kubernetes)
- [Groundwork Notifications Setup](../../../docs/NOTIFICATIONS_SETUP.md)

