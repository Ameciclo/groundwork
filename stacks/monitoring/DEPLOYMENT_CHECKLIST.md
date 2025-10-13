# Monitoring Stack Deployment Checklist

## Pre-deployment Requirements

### 1. Kong Gateway Network
- [ ] Ensure Kong Gateway stack is deployed and running
- [ ] Verify the network `kong-gateway_kong-net` exists
- [ ] Confirm Kong is accessible and healthy

### 2. Environment Variables
- [ ] Copy `.env.example` to `.env` (or set in Portainer)
- [ ] Update the following required variables:
  - `GRAFANA_ADMIN_PASSWORD` - Set a secure password
  - `GRAFANA_ROOT_URL` - Set to your domain (e.g., https://grafana.yourdomain.com)
  - All other variables can use defaults or be customized as needed

### 3. File Structure Verification
Ensure all these files are present in the monitoring directory:
- [ ] `docker-compose.yml`
- [ ] `prometheus.yml`
- [ ] `alert.rules`
- [ ] `loki.yml`
- [ ] `promtail.yml`
- [ ] `grafana/provisioning/datasources/prometheus.yml`
- [ ] `grafana/provisioning/dashboards/dashboards.yml`
- [ ] `grafana/provisioning/dashboards/kestra.json`
- [ ] `grafana/provisioning/dashboards/loki-logs.json`

## Portainer Deployment Steps

### 1. Create Stack in Portainer
1. Go to Stacks → Add stack
2. Choose "Git repository" or "Upload"
3. If using Git:
   - Repository URL: Your repository URL
   - Reference: main/master branch
   - Compose path: `stacks/monitoring/docker-compose.yml`
4. If uploading: Upload the `docker-compose.yml` file

### 2. Environment Variables
Set these environment variables in Portainer:
```
PROMETHEUS_VERSION=v2.45.0
PROMETHEUS_PORT=9090
GRAFANA_VERSION=10.0.3
GRAFANA_PORT=3001
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your_secure_password_here
GRAFANA_ROOT_URL=https://grafana.yourdomain.com
CADVISOR_VERSION=v0.47.2
CADVISOR_PORT=8081
NODE_EXPORTER_VERSION=v1.6.1
NODE_EXPORTER_PORT=9100
LOKI_VERSION=2.9.0
LOKI_PORT=3100
PROMTAIL_VERSION=2.9.0
```

### 3. Deploy Stack
- [ ] Click "Deploy the stack"
- [ ] Wait for all services to start (check logs if any fail)

## Post-deployment Verification

### 1. Service Health Checks
- [ ] Prometheus: http://your-server-ip:9090
- [ ] Grafana: http://your-server-ip:3001
- [ ] cAdvisor: http://your-server-ip:8081
- [ ] Node Exporter: http://your-server-ip:9100/metrics
- [ ] Loki: http://your-server-ip:3100/ready

### 2. Grafana Configuration
- [ ] Log into Grafana with admin credentials
- [ ] Verify Prometheus data source is working
- [ ] Verify Loki data source is working
- [ ] Check that dashboards are loaded
- [ ] Test log queries in Explore section

### 3. Kong Gateway Integration
- [ ] Configure Kong service for Grafana (see `kong-grafana-service.yml`)
- [ ] Test external access through Kong
- [ ] Verify SSL/TLS if configured

## Troubleshooting

### Common Issues
1. **Services not starting**: Check Portainer logs for each service
2. **Network connectivity**: Ensure `kong-gateway_kong-net` network exists
3. **Volume permissions**: Check if services have proper write access to volumes
4. **Configuration files**: Verify all config files are properly mounted

### Log Locations
- Portainer: Check individual service logs in Portainer UI
- Prometheus: Check targets page at /targets endpoint
- Grafana: Check data source settings and test connections
- Loki: Check /ready endpoint and Promtail logs

## Security Considerations

### Before Production
- [ ] Change default Grafana admin password
- [ ] Configure Kong authentication for Grafana
- [ ] Set up proper SSL/TLS certificates
- [ ] Review and restrict network access
- [ ] Configure backup for Grafana dashboards and Prometheus data
- [ ] Set up log retention policies for Loki

### Recommended Kong Plugins
- [ ] Basic Auth or OIDC for authentication
- [ ] Rate Limiting to prevent abuse
- [ ] CORS if needed for web access
- [ ] Request/Response logging for audit

## Monitoring the Monitoring

### Key Metrics to Watch
- [ ] Prometheus storage usage
- [ ] Grafana response times
- [ ] Loki ingestion rate
- [ ] Container resource usage
- [ ] Log volume and retention

### Alerts to Configure
- [ ] Prometheus target down
- [ ] High memory/CPU usage
- [ ] Disk space running low
- [ ] Loki ingestion failures
