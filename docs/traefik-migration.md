# Traefik Migration Guide

## Current Situation

The K3s VM currently has **K3s built-in Traefik** (v34.2.0) running.

However, the repository defines an **ArgoCD-managed Traefik** (v37.2.0) in `kubernetes/infrastructure/traefik/`.

These two will conflict if both are deployed.

## The Solution

**Disable K3s built-in Traefik** and use the ArgoCD-managed version instead.

### Why?

✅ **Full control** - Customize Traefik configuration via GitOps  
✅ **Newer version** - v37.2.0 vs v34.2.0  
✅ **GitOps-managed** - All configuration in Git  
✅ **Let's Encrypt** - Automatic HTTPS certificates  
✅ **Dashboard** - Traefik dashboard enabled  
✅ **Metrics** - Prometheus metrics enabled  

## Migration Options

### Option 1: Re-provision the VM ✅ **RECOMMENDED**

The cleanest approach - start fresh with the correct configuration.

**Steps:**

1. **Destroy current infrastructure:**
   ```bash
   cd infrastructure/pulumi
   pulumi destroy --yes
   ```

2. **Re-deploy infrastructure:**
   ```bash
   pulumi up --yes
   ```

3. **Re-run Ansible:**
   ```bash
   cd ../../automation/ansible
   ./update-inventory.sh
   export TAILSCALE_OAUTH_CLIENT_ID="..."
   export TAILSCALE_OAUTH_CLIENT_SECRET="..."
   ansible-playbook -i inventory.yml k3s-bootstrap-playbook.yml
   ```

4. **Deploy Tailscale via ArgoCD:**
   ```bash
   ssh azureuser@$(cd ../../infrastructure/pulumi && pulumi stack output k3sPublicIp)
   kubectl apply -f kubernetes/argocd/infrastructure/tailscale.yaml
   ```

5. **Deploy Traefik via ArgoCD:**
   ```bash
   kubectl apply -f kubernetes/environments/prod/traefik-app.yaml
   ```

**Time:** ~20-30 minutes  
**Risk:** Low (clean slate)

### Option 2: Manual Migration (Keep Current VM)

Disable K3s Traefik on the running VM without re-provisioning.

**Steps:**

1. **SSH into the VM:**
   ```bash
   ssh azureuser@135.234.25.108
   ```

2. **Uninstall K3s built-in Traefik:**
   ```bash
   # Delete Traefik resources
   kubectl delete helmchart traefik -n kube-system
   kubectl delete helmchart traefik-crd -n kube-system
   
   # Wait for pods to terminate
   kubectl wait --for=delete pod -l app.kubernetes.io/name=traefik -n kube-system --timeout=60s
   
   # Delete remaining resources
   kubectl delete deployment traefik -n kube-system
   kubectl delete service traefik -n kube-system
   kubectl delete daemonset svclb-traefik -n kube-system
   ```

3. **Reconfigure K3s to disable Traefik:**
   ```bash
   # Edit K3s service
   sudo nano /etc/systemd/system/k3s.service
   
   # Add --disable traefik to ExecStart line
   # Should look like:
   # ExecStart=/usr/local/bin/k3s server --tls-san=10.10.1.4 --disable traefik
   
   # Reload and restart K3s
   sudo systemctl daemon-reload
   sudo systemctl restart k3s
   ```

4. **Deploy ArgoCD-managed Traefik:**
   ```bash
   kubectl apply -f kubernetes/environments/prod/traefik-app.yaml
   ```

5. **Verify:**
   ```bash
   kubectl get pods -n kube-system | grep traefik
   kubectl get helmchart -n kube-system
   ```

**Time:** ~10 minutes  
**Risk:** Medium (manual changes to running system)

### Option 3: Keep K3s Traefik (Not Recommended)

Remove the ArgoCD Traefik application and keep K3s's built-in version.

**Why not recommended:**
- ❌ Older version (v34.2.0)
- ❌ Not GitOps-managed
- ❌ Harder to customize
- ❌ No Let's Encrypt configuration
- ❌ No dashboard

**Only do this if:**
- You don't need custom Traefik configuration
- You're okay with the older version
- You don't want to re-provision

## Recommended Approach

**Re-provision the VM (Option 1)** for a clean, production-ready setup.

The Ansible playbook is already updated with `--disable traefik`, so new deployments will work correctly.

## After Migration

Once you have ArgoCD-managed Traefik running:

1. **Verify Traefik is running:**
   ```bash
   kubectl get pods -n kube-system | grep traefik
   kubectl get svc -n kube-system | grep traefik
   ```

2. **Check Traefik version:**
   ```bash
   kubectl get helmchart traefik -n kube-system -o yaml | grep version
   ```
   Should show: `version: 37.2.0`

3. **Access Traefik dashboard:**
   - Via Tailscale: `https://traefik.<your-tailnet>.ts.net`
   - Or port-forward: `kubectl port-forward -n kube-system svc/traefik 9000:9000`

4. **Deploy applications:**
   - Strapi
   - Atlas
   - Zitadel

All ingresses will now use the ArgoCD-managed Traefik with Let's Encrypt!

## Questions?

- **Will I lose data?** - No database data is stored on the VM. PostgreSQL is on Azure.
- **What about ArgoCD?** - ArgoCD will be re-deployed by Ansible.
- **What about Tailscale?** - Tailscale will be re-deployed by ArgoCD.
- **How long is downtime?** - ~20-30 minutes total.

## Summary

| Option | Time | Risk | Recommended |
|--------|------|------|-------------|
| Re-provision VM | 20-30 min | Low | ✅ Yes |
| Manual migration | 10 min | Medium | ⚠️ Maybe |
| Keep K3s Traefik | 0 min | Low | ❌ No |

**Recommendation: Re-provision the VM for a clean, production-ready setup.**

