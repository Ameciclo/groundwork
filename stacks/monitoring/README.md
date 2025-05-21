# Monitoring Stack

This directory contains a Docker Swarm stack for monitoring your infrastructure using Prometheus and Grafana.

## Components

- **Prometheus**: Time series database for metrics collection
- **Grafana**: Visualization and dashboarding
- **cAdvisor**: Container metrics collector
- **Node Exporter**: Host system metrics collector

## Deployment with Portainer

1. In Portainer, go to Stacks > Add stack
2. Select "Git repository"
3. Enter your repository URL
4. Specify the path to this stack: `stacks/monitoring/docker-compose.yml`
5. Add your environment variables (see `.env.example` for reference)
6. Deploy the stack

## Accessing the Services

After deployment, you can access:

- **Prometheus**: http://your-server-ip:9090
- **Grafana**: http://your-server-ip:3001
- **cAdvisor**: http://your-server-ip:8080
- **Node Exporter**: http://your-server-ip:9100 (metrics endpoint)

## Initial Grafana Setup

1. Log in to Grafana with the credentials you set in the environment variables
2. Add Prometheus as a data source:
   - Go to Configuration > Data Sources > Add data source
   - Select Prometheus
   - Set URL to `http://prometheus:9090`
   - Click "Save & Test"

3. Import dashboards:
   - Go to Dashboards > Import
   - Import dashboard ID 1860 for Node Exporter
   - Import dashboard ID 893 for Docker

## Customizing Prometheus Configuration

The Prometheus configuration is stored in the `prometheus.yml` file. To modify it:

1. Edit the `prometheus.yml` file in this directory
2. Add or modify scrape targets as needed
3. Update the stack in Portainer

## Adding Alert Rules

Alert rules are defined in the `alert.rules` file. To add more alerts:

1. Edit the `alert.rules` file in this directory
2. Add your alert rules following the PromQL syntax
3. Update the stack in Portainer

## Initial Setup

Before deploying the stack for the first time, you need to create the configuration volumes:

```bash
# On your Docker Swarm manager node
docker volume create monitoring_prometheus_config
docker volume create monitoring_alert_rules

# Copy the configuration files to the volumes
docker run --rm -v $(pwd)/prometheus.yml:/src/prometheus.yml -v monitoring_prometheus_config:/dest alpine cp /src/prometheus.yml /dest/
docker run --rm -v $(pwd)/alert.rules:/src/alert.rules -v monitoring_alert_rules:/dest alpine cp /src/alert.rules /dest/
```

## Security Considerations

- Change the default Grafana admin password
- Consider setting up a reverse proxy with HTTPS
- Restrict access to the monitoring services using network rules

## Troubleshooting

- **Prometheus not scraping targets**: Check the Prometheus targets page at http://your-server-ip:9090/targets
- **Grafana can't connect to Prometheus**: Verify the data source URL is correct
- **Missing container metrics**: Ensure cAdvisor has access to Docker socket
