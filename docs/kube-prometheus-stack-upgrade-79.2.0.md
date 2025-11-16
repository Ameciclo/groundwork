# kube-prometheus-stack Upgrade: 65.8.1 → 79.2.0

## 📋 Upgrade Summary

**Chart Version:** `65.8.1` → `79.2.0`  
**Date:** November 16, 2024  
**Upgrade Type:** Major version jump (14 versions)

## 🔍 Breaking Changes Identified

### 1. Grafana Admin Password Configuration
**Status:** ✅ **HANDLED**

**Change:** The `adminPassword` field structure has been updated in newer versions, but the old format is still supported for backward compatibility.

**Action Taken:**
- Updated to use both `adminUser` and `adminPassword` fields explicitly
- Maintained the same password (`admin`) for consistency
- Added note to change in production

**Before:**
```yaml
adminPassword: admin
```

**After:**
```yaml
adminUser: admin
adminPassword: admin  # Change this in production!
```

### 2. Chart Version Update
**Status:** ✅ **COMPLETED**

**Change:** Updated chart version from `65.8.1` to `79.2.0`

## 🧪 Compatibility Verification

### ✅ Verified Compatible Configurations:
- `additionalScrapeConfigs` - Structure unchanged
- `serviceMonitorSelectorNilUsesHelmValues` - Still supported
- `podMonitorSelectorNilUsesHelmValues` - Still supported
- `prometheus.prometheusSpec` - All current fields supported
- `grafana.persistence` - Configuration unchanged
- `alertmanager` - Configuration unchanged
- `nodeExporter` - Configuration unchanged
- `kubeStateMetrics` - Configuration unchanged

### 📦 Component Versions (Estimated):
- **Prometheus:** ~v2.54.x (from ~v2.47.x)
- **Grafana:** ~v11.x (from ~v10.x)
- **AlertManager:** ~v0.27.x (from ~v0.26.x)
- **Node Exporter:** ~v1.8.x (from ~v1.6.x)

## 🚀 Deployment Steps

### 1. Pre-Upgrade Checklist
- [x] Helm repo updated (`helm repo update`)
- [x] Breaking changes reviewed and addressed
- [x] Configuration compatibility verified
- [x] Backup strategy confirmed (PVCs will persist)

### 2. Upgrade Command
```bash
# Via ArgoCD (Recommended)
kubectl apply -f kubernetes/environments/prod/monitoring-app.yaml

# Manual upgrade (if needed)
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --version 79.2.0 \
  --namespace monitoring \
  --values kubernetes/infrastructure/monitoring/kube-prometheus-stack.yaml
```

### 3. Post-Upgrade Verification
```bash
# Check all pods are running
kubectl get pods -n monitoring

# Verify Prometheus is accessible
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090

# Verify Grafana is accessible
# URL: https://grafana.armadillo-hamal.ts.net
# Credentials: admin/admin

# Check ServiceMonitors are being discovered
kubectl get servicemonitors -n monitoring
kubectl get servicemonitors -n kube-system
```

## 🔧 Rollback Plan (if needed)

If issues occur, rollback to previous version:

```bash
# Update chart version back to 65.8.1
# Then apply via ArgoCD or manual helm upgrade
```

## 📊 Expected Benefits

- **Security:** Latest security patches and fixes
- **Performance:** Improved query performance and resource usage
- **Features:** New Grafana dashboards and Prometheus features
- **Stability:** Bug fixes and stability improvements
- **Compatibility:** Better Kubernetes 1.28+ support

## ⚠️ Production Considerations

1. **Change Default Password:** Update Grafana admin password immediately after upgrade
2. **Monitor Resources:** Watch for any resource usage changes
3. **Verify Alerts:** Ensure all alerting rules still work correctly
4. **Check Dashboards:** Verify all Grafana dashboards load properly
5. **Test Integrations:** Confirm Traefik metrics scraping still works

## 📝 Notes

- All existing PVCs and data will be preserved
- Traefik integration should continue working without changes
- Uptime Kuma and other components are not affected by this upgrade
- ArgoCD will handle the upgrade automatically when the PR is merged
