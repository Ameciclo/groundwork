# Monitoring Stack - Prometheus + Grafana

Complete monitoring solution for the Ameciclo Kubernetes cluster.

## 📦 What's Included

### Core Components

- **Prometheus** - Metrics collection and storage
  - 15 days retention
  - 15GB storage
  - Scrapes Traefik, K8s components, and node metrics

- **Grafana** - Visualization and dashboards
  - Pre-configured Traefik dashboard
  - Default K8s dashboards
  - Accessible via Tailscale

- **Uptime Kuma** - Uptime monitoring and status page
  - Monitor HTTP(s), TCP, DNS, Ping
  - Beautiful status pages
  - Notifications (Telegram, Slack, email, etc.)
  - Accessible via Tailscale (optional public access)

- **AlertManager** - Alert routing and notifications
  - Can integrate with Telegram, Slack, email
  - 2GB storage for alert history

- **Node Exporter** - System-level metrics
  - CPU, memory, disk, network
  - Per-node metrics

- **Kube State Metrics** - Kubernetes object metrics
  - Pods, deployments, services status
  - Resource usage

### Traefik Integration

- **ServiceMonitor** - Automatic Traefik metrics scraping
- **Metrics Service** - Exposes Traefik metrics endpoint
- **Dashboard** - Pre-configured Traefik overview dashboard

## 🚀 Deployment

### Via ArgoCD (Recommended)

```bash
kubectl apply -f kubernetes/environments/prod/monitoring-app.yaml
```

ArgoCD will automatically deploy and manage the monitoring stack.

### Manual Deployment

```bash
kubectl apply -k kubernetes/infrastructure/monitoring/
```

## 🔐 Access

### Grafana Dashboard

**URL:** `https://grafana.armadillo-hamal.ts.net` (Private - Tailscale only)

**Default Credentials:**
- Username: `admin`
- Password: `admin`

⚠️ **Change the password immediately after first login!**

### Uptime Kuma Status Page

**URL:** `https://status.az.ameciclo.org` (Public)

**First-time Setup:**
- Visit the URL and create admin account
- First user becomes admin
- See [UPTIME_KUMA.md](UPTIME_KUMA.md) for detailed setup guide

### Prometheus UI

Port-forward to access Prometheus:

```bash
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090
```

Then open: `http://localhost:9090`

### AlertManager UI

Port-forward to access AlertManager:

```bash
kubectl port-forward -n monitoring svc/prometheus-alertmanager 9093:9093
```

Then open: `http://localhost:9093`

## 📊 Pre-configured Dashboards

### Traefik Overview
- Requests per second by service
- Error rates (4xx, 5xx)
- Response time percentiles
- Active connections
- Bandwidth usage

### Kubernetes Dashboards
- Cluster overview
- Node metrics
- Pod metrics
- Namespace resource usage
- Persistent volume usage

## 🔍 Useful Prometheus Queries

### Traefik Metrics

**Total requests per second:**
```promql
sum(rate(traefik_service_requests_total[5m]))
```

**Requests by service:**
```promql
sum(rate(traefik_service_requests_total[5m])) by (service)
```

**Error rate:**
```promql
sum(rate(traefik_service_requests_total{code=~"5.."}[5m])) / sum(rate(traefik_service_requests_total[5m]))
```

**Response time (p95):**
```promql
histogram_quantile(0.95, sum(rate(traefik_service_request_duration_seconds_bucket[5m])) by (le, service))
```

**Active connections:**
```promql
traefik_entrypoint_open_connections
```

## 🔔 Setting Up Alerts

### Example: High Error Rate Alert

Create a PrometheusRule:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: traefik-alerts
  namespace: monitoring
spec:
  groups:
    - name: traefik
      interval: 30s
      rules:
        - alert: HighErrorRate
          expr: |
            sum(rate(traefik_service_requests_total{code=~"5.."}[5m])) 
            / 
            sum(rate(traefik_service_requests_total[5m])) 
            > 0.01
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High error rate detected"
            description: "Error rate is {{ $value | humanizePercentage }}"
```

## 📈 Resource Usage

**Expected resource consumption:**

| Component | CPU Request | Memory Request | Storage |
|-----------|-------------|----------------|---------|
| Prometheus | 200m | 512Mi | 15Gi |
| Grafana | 100m | 256Mi | 5Gi |
| Uptime Kuma | 100m | 128Mi | 2Gi |
| AlertManager | 50m | 128Mi | 2Gi |
| Node Exporter | 50m | 64Mi | - |
| Kube State Metrics | 50m | 128Mi | - |
| **Total** | **~550m** | **~1.2Gi** | **24Gi** |

## 🔧 Configuration

### Change Grafana Password

1. Access Grafana
2. Click on user icon → Profile
3. Change password

Or via kubectl:

```bash
kubectl exec -n monitoring deploy/prometheus-grafana -- grafana-cli admin reset-admin-password <new-password>
```

### Adjust Retention

Edit `kube-prometheus-stack.yaml`:

```yaml
prometheus:
  prometheusSpec:
    retention: 30d  # Change from 15d to 30d
    retentionSize: "20GB"  # Increase storage
```

### Add More Dashboards

Import dashboards from [Grafana.com](https://grafana.com/grafana/dashboards/):

1. Go to Grafana → Dashboards → Import
2. Enter dashboard ID (e.g., 17346 for Traefik)
3. Select Prometheus datasource
4. Import

## 🐛 Troubleshooting

### Prometheus not scraping Traefik

Check ServiceMonitor:
```bash
kubectl get servicemonitor -n kube-system traefik
```

Check Prometheus targets:
```bash
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090
# Open http://localhost:9090/targets
```

### Grafana not accessible

Check ingress:
```bash
kubectl get ingress -n monitoring grafana
kubectl get pods -n tailscale | grep grafana
```

### High memory usage

Reduce retention or scrape interval:
```yaml
prometheus:
  prometheusSpec:
    retention: 7d  # Reduce retention
```

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Traefik Metrics](https://doc.traefik.io/traefik/observability/metrics/prometheus/)

