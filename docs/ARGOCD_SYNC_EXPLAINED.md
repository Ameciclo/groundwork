# ArgoCD Sync Explained

## What Happened

You pushed changes to the groundwork repo (changed strapi version), but ArgoCD didn't immediately show the changes as "OutOfSync". Here's why:

## How ArgoCD Sync Works

```
You push to git
    ↓
ArgoCD polls git repository (every 3 minutes by default)
    ↓
ArgoCD detects changes
    ↓
Shows "OutOfSync" status
    ↓
Auto-sync kicks in (if enabled)
    ↓
ArgoCD applies changes to cluster
    ↓
Shows "Synced" status
```

## Why You Didn't See Changes Immediately

**Reason:** ArgoCD polls the git repository on a schedule (default: 3 minutes)

If you push changes and check immediately, ArgoCD might not have polled yet!

## Solution: Manual Refresh

You can manually trigger a refresh instead of waiting:

```bash
# Option 1: Using kubectl patch (what we did)
kubectl patch application strapi -n argocd \
  --type merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Option 2: Using argocd CLI
argocd app get strapi --refresh hard

# Option 3: Using ArgoCD UI
# Click the "Refresh" button in the ArgoCD dashboard
```

## What Happened in Your Case

1. ✅ You pushed strapi version change to groundwork repo
2. ✅ We manually refreshed the strapi application
3. ✅ ArgoCD detected the new revision: `c73a024`
4. ✅ Auto-sync triggered (because it's enabled)
5. ✅ New pods started with new image: `ghcr.io/ameciclo/strapi:0.1.0-06b32e8`
6. ✅ Rolling update completed (old pods terminated, new pods running)

## Sync Status Meanings

| Status | Meaning | Action |
|--------|---------|--------|
| **Synced** | Cluster matches git | Nothing needed |
| **OutOfSync** | Cluster differs from git | Auto-sync will apply changes |
| **Progressing** | Changes being applied | Wait for completion |
| **Unknown** | Can't determine status | Check connectivity |

## Auto-Sync Configuration

Your strapi application has auto-sync enabled:

```yaml
spec:
  syncPolicy:
    automated:
      prune: true      # Delete resources not in git
      selfHeal: true   # Reapply if manually changed
```

This means:
- ✅ Changes are automatically applied
- ✅ Manual changes are reverted
- ✅ Deleted resources are removed

## Polling Interval

Default: 3 minutes

To check/change it:
```bash
# View current setting
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml | grep timeout

# Change it (requires restart)
kubectl patch configmap argocd-cmd-params-cm -n argocd \
  -p '{"data":{"application.instanceLabelKey":"argocd.argoproj.io/instance","server.disable.auth":"false","server.insecure":"false","application.resourceTrackingMethod":"annotation","timeout.reconciliation":"180s"}}'
```

## Best Practices

1. **Use manual refresh during development** - Don't wait 3 minutes
2. **Use webhooks in production** - Instant sync on push
3. **Monitor sync status** - Check ArgoCD dashboard regularly
4. **Use auto-sync** - Ensures cluster always matches git
5. **Test changes locally first** - Before pushing to git

## Webhook Setup (Optional)

For instant sync on push (no 3-minute wait):

1. Get your ArgoCD webhook URL
2. Add it to GitHub repository settings
3. ArgoCD will sync immediately on push

This is recommended for production!

## Troubleshooting

**Application shows OutOfSync but won't sync:**
- Check auto-sync is enabled: `kubectl get application strapi -n argocd -o jsonpath='{.spec.syncPolicy}'`
- Check for errors: `kubectl describe application strapi -n argocd`

**Changes not appearing after refresh:**
- Check git push succeeded: `git log --oneline -1`
- Check ArgoCD can access repo: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server`

**Sync taking too long:**
- Check pod logs: `kubectl logs -n strapi -l app.kubernetes.io/name=strapi`
- Check resource limits: `kubectl describe deployment strapi -n strapi`

