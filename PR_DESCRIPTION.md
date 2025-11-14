# Add Monitoring Stack: Prometheus + Grafana

## 📊 Overview

This PR adds a complete monitoring solution to the Ameciclo infrastructure using **Prometheus** for metrics collection and **Grafana** for visualization.

## ✨ What's New

### Core Components

- **Prometheus** - Metrics collection and time-series database
  - 15 days retention
  - 15GB storage
  - Automatic scraping of Traefik, K8s components, and nodes

- **Grafana** - Visualization and dashboards
  - Accessible via Tailscale: `https://grafana.armadillo-hamal.ts.net` (Private)
  - Pre-configured Traefik dashboard
  - Default Kubernetes dashboards
  - Default credentials: `admin/admin` (change on first login!)

- **Uptime Kuma** - Uptime monitoring and status page
  - Public URL: `https://status.az.ameciclo.org`
  - Monitor HTTP(s), TCP, DNS, Ping
  - Beautiful public status pages
  - Notifications (Telegram, Slack, email, etc.)
  - First user becomes admin

- **AlertManager** - Alert routing and notifications
  - Ready for Telegram/Slack integration
  - 2GB storage for alert history

- **Node Exporter** - System-level metrics (CPU, memory, disk, network)

- **Kube State Metrics** - Kubernetes object metrics (pods, deployments, services)

### Traefik Integration

- **ServiceMonitor** - Automatic Traefik metrics scraping every 30s
- **Metrics Service** - Exposes Traefik metrics endpoint (port 9100)
- **Custom Dashboard** - Pre-configured Traefik overview dashboard

## 📈 Insights You'll Get

### Traffic Analytics
- Request volume over time
- Traffic by service (Strapi, Atlas, Zitadel)
- Peak usage patterns
- Growth trends

### Performance Monitoring
- Response times (p50, p95, p99)
- Slow endpoints identification
- Performance degradation detection
- Backend health status

### Error Tracking
- Error rates (4xx, 5xx)
- Error trends over time
- Service availability/uptime
- Failed requests by service

### Resource Utilization
- CPU and memory usage
- Active connections
- Request queues
- Pod health status

## 📁 Files Added

```
kubernetes/infrastructure/monitoring/
├── README.md                           # Comprehensive monitoring docs
├── UPTIME_KUMA.md                      # Uptime Kuma setup guide
├── namespace.yaml                      # monitoring namespace
├── kube-prometheus-stack.yaml          # Main Helm chart
├── traefik-servicemonitor.yaml         # Traefik metrics scraping
├── traefik-metrics-service.yaml        # Traefik metrics service
├── grafana-ingress.yaml                # Tailscale ingress for Grafana
├── uptime-kuma-deployment.yaml         # Uptime Kuma deployment
├── uptime-kuma-ingress.yaml            # Public Traefik ingress for Uptime Kuma
├── traefik-dashboard-configmap.yaml    # Pre-configured dashboard
└── kustomization.yaml                  # Kustomize config

kubernetes/environments/prod/
└── monitoring-app.yaml                 # ArgoCD application

docs/
└── monitoring-setup.md                 # Deployment and usage guide
```

## 🚀 Deployment

### Automatic (via ArgoCD)

```bash
kubectl apply -f kubernetes/environments/prod/monitoring-app.yaml
```

ArgoCD will automatically deploy all components.

### Manual

```bash
kubectl apply -k kubernetes/infrastructure/monitoring/
```

## 🔐 Access

**Grafana Dashboard (Private - Tailscale):**
- URL: `https://grafana.armadillo-hamal.ts.net`
- Username: `admin`
- Password: `admin` (⚠️ change immediately!)

**Uptime Kuma Status Page (Public):**
- URL: `https://status.az.ameciclo.org`
- First-time: Create admin account
- See [UPTIME_KUMA.md](kubernetes/infrastructure/monitoring/UPTIME_KUMA.md) for setup

**Prometheus UI (port-forward):**
```bash
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090
```

## 📊 Pre-configured Dashboards

1. **Traefik Overview** - Custom dashboard with:
   - Requests per second by service
   - Error rates (5xx)
   - Response time percentiles
   - Active connections

2. **Kubernetes Cluster** - Resource usage across the cluster

3. **Node Metrics** - Server-level metrics (CPU, RAM, disk, network)

4. **Pod Metrics** - Per-pod resource consumption

## 💾 Resource Requirements

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Prometheus | 200m-1000m | 512Mi-2Gi | 15Gi |
| Grafana | 100m-500m | 256Mi-512Mi | 5Gi |
| Uptime Kuma | 100m-500m | 128Mi-512Mi | 2Gi |
| AlertManager | 50m-200m | 128Mi-256Mi | 2Gi |
| Node Exporter | 50m | 64Mi | - |
| Kube State Metrics | 50m | 128Mi | - |
| **Total** | **~550m-2500m** | **~1.2Gi-3.5Gi** | **24Gi** |

## 🔍 Example Queries

**Total requests per second:**
```promql
sum(rate(traefik_service_requests_total[5m]))
```

**Error rate percentage:**
```promql
100 * sum(rate(traefik_service_requests_total{code=~"5.."}[5m])) / sum(rate(traefik_service_requests_total[5m]))
```

**95th percentile response time:**
```promql
histogram_quantile(0.95, sum(rate(traefik_service_request_duration_seconds_bucket[5m])) by (le, service))
```

## 🔔 Future Enhancements

- [ ] Telegram alert integration
- [ ] Custom alerts for high error rates
- [ ] Custom alerts for slow response times
- [ ] Application-specific dashboards (Strapi, Atlas, Zitadel)
- [ ] Long-term metrics storage (Thanos/Cortex)

## 📚 Documentation

- [Monitoring Setup Guide](docs/monitoring-setup.md) - Complete deployment and usage guide
- [Monitoring README](kubernetes/infrastructure/monitoring/README.md) - Technical details and configuration

## ✅ Testing Checklist

- [ ] Deploy monitoring stack via ArgoCD
- [ ] Verify all pods are running in `monitoring` namespace
- [ ] Access Grafana via Tailscale
- [ ] Verify Traefik metrics are being scraped
- [ ] Check pre-configured dashboards load correctly
- [ ] Test Prometheus queries
- [ ] Verify storage persistence (PVCs created)

## 🎯 Benefits

✅ **Visibility** - See what's happening in real-time  
✅ **Proactive** - Detect issues before users complain  
✅ **Data-driven** - Make informed infrastructure decisions  
✅ **Cost optimization** - Identify underutilized resources  
✅ **Performance** - Track and improve response times  
✅ **Reliability** - Monitor uptime and availability  

## 📸 Screenshots

(Add screenshots after deployment showing Grafana dashboards)

---

**Ready to merge?** This adds production-grade monitoring to the infrastructure! 🚀

