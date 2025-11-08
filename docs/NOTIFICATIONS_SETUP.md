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

### 3. Enhanced Notifications ConfigMap

The enhanced notifications are configured via the `argocd-notifications-cm` ConfigMap:

```yaml
# Location: helm/environments/prod/argocd-notifications-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.telegram: |
    token: $telegram-token
    chatID: $telegram-chatid

  # Custom templates with emojis and rich formatting
  template.app-deployed: |
    message: |
      🚀 **Deployment Successful**
      📦 **Application:** `{{.app.metadata.name}}`
      # ... (see full template in the file)
```

### 4. Application Subscriptions

Applications are configured to send enhanced notifications:

```yaml
metadata:
  annotations:
    # Enhanced Telegram notifications
    notifications.argoproj.io/subscribe.on-deployed.telegram: ""
    notifications.argoproj.io/subscribe.on-sync-failed.telegram: ""
    notifications.argoproj.io/subscribe.on-health-degraded.telegram: ""
    notifications.argoproj.io/subscribe.on-sync-running.telegram: ""
    notifications.argoproj.io/subscribe.on-sync-status-unknown.telegram: ""
```

## Enhanced Notification Templates

The system now includes beautifully formatted Telegram notifications with emojis and detailed information:

### Available Notification Types

- **🚀 on-deployed**: When application successfully deploys
  - Shows deployment success with green checkmarks
  - Includes sync details, revision info, and resource status
  - Links to ArgoCD dashboard and repository

- **❌ on-sync-failed**: When sync operation fails
  - Shows error details and failure information
  - Includes troubleshooting suggestions
  - Links to ArgoCD for investigation

- **🟡 on-health-degraded**: When application health degrades
  - Shows health status and affected resources
  - Provides action items for resolution
  - Monitors for recovery

- **🔄 on-sync-running**: When deployment is in progress
  - Shows real-time sync status
  - Includes operation details and timing

- **❓ on-sync-status-unknown**: When application status is unclear
  - Alerts for connectivity or configuration issues
  - Provides troubleshooting steps

### Notification Features

✨ **Enhanced Formatting:**
- Rich text with emojis and formatting
- Structured information layout
- Clickable links to ArgoCD and repository

📊 **Detailed Information:**
- Application name and environment
- Sync and health status
- Operation IDs and timestamps
- Git revision and repository details
- Resource-level status information

🔗 **Quick Access:**
- Direct links to ArgoCD dashboard
- Repository links for code review
- Formatted for easy mobile reading

## Deployment

### Applying the Enhanced Notifications

1. **Deploy the ConfigMap:**
   ```bash
   kubectl apply -f helm/environments/prod/argocd-notifications-cm.yaml
   ```

2. **Update Application Manifests:**
   ```bash
   kubectl apply -f helm/environments/prod/strapi-app.yaml
   kubectl apply -f helm/environments/prod/atlas-app.yaml
   kubectl apply -f helm/environments/prod/atlas-docs-app.yaml
   kubectl apply -f helm/environments/prod/traefik-app.yaml
   ```

3. **Restart ArgoCD Notifications Controller:**
   ```bash
   kubectl rollout restart deployment argocd-notifications-controller -n argocd
   ```

### Verification

Check that notifications are working:

```bash
# Check notification controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller

# Verify ConfigMap is loaded
kubectl get configmap argocd-notifications-cm -n argocd -o yaml

# Test with a manual sync
kubectl patch application strapi -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"now"}}}' --type merge
```

## Customization

### Modifying Templates

To customize notification templates:

1. Edit `helm/environments/prod/argocd-notifications-cm.yaml`
2. Modify the template content under `template.app-deployed`, etc.
3. Apply the changes: `kubectl apply -f helm/environments/prod/argocd-notifications-cm.yaml`
4. Restart the controller: `kubectl rollout restart deployment argocd-notifications-controller -n argocd`

### Template Variables

Available variables in templates:
- `{{.app.metadata.name}}` - Application name
- `{{.app.metadata.namespace}}` - Application namespace
- `{{.app.status.sync.status}}` - Sync status
- `{{.app.status.health.status}}` - Health status
- `{{.app.status.sync.revision}}` - Git revision
- `{{.app.spec.source.repoURL}}` - Repository URL
- `{{.app.spec.source.path}}` - Application path
- `{{.app.status.operationState.startedAt}}` - Operation start time
- `{{.app.status.operationState.finishedAt}}` - Operation finish time

### Adding New Triggers

To add custom triggers:

1. Add a new template in the ConfigMap
2. Add a corresponding trigger definition
3. Subscribe applications to the new trigger

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

