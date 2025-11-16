# Monitoring Setup Guide

Complete guide to deploy and use the Prometheus + Grafana monitoring stack.

## 🎯 What You'll Get

After following this guide, you'll have:

✅ **Prometheus** - Collecting metrics from Traefik and Kubernetes
✅ **Grafana** - Beautiful dashboards for visualization
✅ **Uptime Kuma** - Public status page and uptime monitoring
✅ **Traefik Metrics** - Request rates, errors, latency, etc.
✅ **K8s Metrics** - Cluster health, resource usage
✅ **Alerts** - Get notified when things go wrong

## 📋 Prerequisites

- ✅ K3s cluster running
- ✅ ArgoCD deployed
- ✅ Traefik deployed
- ✅ Tailscale configured
- ✅ At least 2GB free memory on the cluster
- ✅ At least 25GB free disk space

## 🚀 Quick Start

### Step 1: Create Grafana Admin Secret

**⚠️ REQUIRED: Must be done before deployment!**

```bash
# Create Grafana admin credentials with strong password
./kubernetes/infrastructure/monitoring/create-grafana-secret.sh

# Save the generated password securely!
```

### Step 2: Deploy Monitoring Stack

```bash
# Apply the ArgoCD application
kubectl apply -f kubernetes/environments/prod/monitoring-app.yaml

# Watch the deployment
kubectl get pods -n monitoring -w
```

Wait for all pods to be running (takes ~3-5 minutes):
- `prometheus-prometheus-0`
- `prometheus-grafana-xxx`
- `uptime-kuma-xxx`
- `prometheus-alertmanager-0`
- `prometheus-kube-state-metrics-xxx`
- `prometheus-node-exporter-xxx`

### Step 3: Access Grafana

**URL:** `https://grafana.armadillo-hamal.ts.net`

**Login Credentials:**
- Username: `admin`
- Password: Use the password generated in Step 1

⚠️ **Save the generated password securely - it's only shown once during secret creation!**

### Step 4: Setup Uptime Kuma

**URL:** `https://status.az.ameciclo.org`

1. Visit the URL (first time only)
2. Create admin account
3. Set a strong password
4. Add monitors for your services (see [UPTIME_KUMA.md](../kubernetes/infrastructure/monitoring/UPTIME_KUMA.md))

**Note:** Make sure DNS is configured to point `status.az.ameciclo.org` to your K3s LoadBalancer IP.

### Step 5: Explore Grafana Dashboards

1. **Traefik Overview** - Custom dashboard for Traefik metrics
2. **Kubernetes / Compute Resources / Cluster** - Cluster overview
3. **Kubernetes / Compute Resources / Namespace (Pods)** - Pod metrics
4. **Node Exporter / Nodes** - Server metrics

## 📊 Understanding the Dashboards

### Traefik Overview Dashboard

**What you see:**
- **Requests per Second** - Traffic volume by service
- **Error Rate** - Percentage of 5xx errors
- **Response Time** - Latency percentiles
- **Status Codes** - Distribution of HTTP codes

**How to use:**
- Monitor traffic patterns
- Identify slow services
- Detect error spikes
- Track service health

### Kubernetes Cluster Dashboard

**What you see:**
- **CPU Usage** - Cluster-wide CPU consumption
- **Memory Usage** - RAM usage across nodes
- **Network I/O** - Bandwidth usage
- **Disk I/O** - Storage performance

**How to use:**
- Capacity planning
- Resource optimization
- Performance troubleshooting

## 🔍 Useful Queries

### Traefik Queries

Open Grafana → Explore → Select Prometheus datasource

**Total requests in last 5 minutes:**
```promql
sum(increase(traefik_service_requests_total[5m]))
```

**Requests per second by service:**
```promql
sum(rate(traefik_service_requests_total[5m])) by (service)
```

**Error rate percentage:**
```promql
100 * sum(rate(traefik_service_requests_total{code=~"5.."}[5m])) / sum(rate(traefik_service_requests_total[5m]))
```

**95th percentile response time:**
```promql
histogram_quantile(0.95, sum(rate(traefik_service_request_duration_seconds_bucket[5m])) by (le, service))
```

**Top 5 slowest services:**
```promql
topk(5, histogram_quantile(0.95, sum(rate(traefik_service_request_duration_seconds_bucket[5m])) by (le, service)))
```

## 🔔 Setting Up Alerts

### Example: Alert on High Error Rate

Create `kubernetes/infrastructure/monitoring/alerts/traefik-alerts.yaml`:

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
        - alert: TraefikHighErrorRate
          expr: |
            (sum(rate(traefik_service_requests_total{code=~"5.."}[5m])) 
            / 
            sum(rate(traefik_service_requests_total[5m]))) > 0.01
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Traefik error rate is high"
            description: "Error rate is {{ $value | humanizePercentage }} (threshold: 1%)"
        
        - alert: TraefikServiceDown
          expr: up{job="traefik"} == 0
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "Traefik is down"
            description: "Traefik has been down for more than 1 minute"
```

Apply:
```bash
kubectl apply -f kubernetes/infrastructure/monitoring/alerts/traefik-alerts.yaml
```

## 📈 Creating Custom Dashboards

### Import Community Dashboards

1. Go to Grafana → Dashboards → Import
2. Enter dashboard ID from [Grafana.com](https://grafana.com/grafana/dashboards/)
3. Popular IDs:
   - `17346` - Traefik Official Dashboard
   - `15172` - Node Exporter Full
   - `15760` - Kubernetes Cluster Monitoring

### Create Your Own Dashboard

1. Dashboards → New → New Dashboard
2. Add Panel
3. Select Prometheus datasource
4. Enter query (e.g., `sum(rate(traefik_service_requests_total[5m]))`)
5. Configure visualization
6. Save dashboard

## 🔧 Advanced Configuration

### Increase Retention Period

Edit `kubernetes/infrastructure/monitoring/kube-prometheus-stack.yaml`:

```yaml
prometheus:
  prometheusSpec:
    retention: 30d  # Change from 15d
    retentionSize: "30GB"  # Increase storage
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 35Gi  # Increase PVC size
```

### Add Telegram Alerts

Configure AlertManager to send alerts to Telegram:

```yaml
alertmanager:
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname']
      receiver: 'telegram'
    receivers:
      - name: 'telegram'
        telegram_configs:
          - bot_token: 'YOUR_BOT_TOKEN'
            chat_id: YOUR_CHAT_ID
            parse_mode: 'HTML'
```

## 🐛 Troubleshooting

### Prometheus not collecting Traefik metrics

**Check ServiceMonitor:**
```bash
kubectl get servicemonitor -n kube-system traefik -o yaml
```

**Check Prometheus targets:**
```bash
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090
# Open http://localhost:9090/targets
# Look for "traefik" job
```

**Check Traefik metrics endpoint:**
```bash
kubectl exec -n kube-system deploy/traefik -- wget -qO- http://localhost:9100/metrics
```

### Grafana shows "No data"

**Check Prometheus datasource:**
1. Grafana → Configuration → Data Sources
2. Click on Prometheus
3. Click "Test" button
4. Should show "Data source is working"

**Check time range:**
- Make sure you're looking at recent data (last 6 hours)
- Adjust time range in top-right corner

### High memory usage

**Reduce scrape interval:**
```yaml
prometheus:
  prometheusSpec:
    scrapeInterval: 60s  # Increase from 30s
```

**Reduce retention:**
```yaml
prometheus:
  prometheusSpec:
    retention: 7d  # Reduce from 15d
```

## 📚 Next Steps

1. **Explore dashboards** - Familiarize yourself with the UI
2. **Set up alerts** - Get notified of issues
3. **Create custom dashboards** - Track your specific metrics
4. **Integrate with Telegram** - Get alerts on your phone
5. **Monitor trends** - Use data for capacity planning

## 🎓 Learning Resources

- [Prometheus Query Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Tutorials](https://grafana.com/tutorials/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Traefik Metrics Documentation](https://doc.traefik.io/traefik/observability/metrics/prometheus/)

