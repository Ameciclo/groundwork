# Monitoring Stack

This directory contains a Docker Swarm stack for monitoring your infrastructure using Prometheus, Grafana, and Loki.

## Components

- **Prometheus**: Time series database for metrics collection
- **Grafana**: Visualization and dashboarding
- **cAdvisor**: Container metrics collector
- **Node Exporter**: Host system metrics collector
- **Loki**: Log aggregation system
- **Promtail**: Log collection agent

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
- **cAdvisor**: http://your-server-ip:8081
- **Node Exporter**: http://your-server-ip:9100 (metrics endpoint)
- **Loki**: http://your-server-ip:3100 (API endpoint)

## Initial Grafana Setup

Grafana is pre-configured with:
- Prometheus data source
- Loki data source
- Essential plugins (Pie Chart, Clock Panel)
- Loki Logs dashboard

After deployment, you can:

1. Log in to Grafana with the credentials you set in the environment variables
2. Import dashboards:
   - Go to Dashboards > Import
   - Import dashboard ID 1860 for Node Exporter
   - Import dashboard ID 893 for Docker
   - Import dashboard ID 3662 for Prometheus Stats

Both Prometheus and Loki data sources are automatically configured via provisioning.

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

## Loki Log Collection

Loki collects logs from various sources via Promtail:

- **Container logs**: Docker container logs from `/var/lib/docker/containers`
- **System logs**: System logs from `/var/log/syslog`
- **Docker daemon logs**: Docker service logs
- **Kernel logs**: Kernel messages from `/var/log/kern.log`

To customize log collection:

1. Edit the `promtail.yml` file in this directory
2. Add or modify scrape configurations
3. Update the stack in Portainer

Logs can be queried in Grafana using LogQL syntax. The pre-configured Loki Logs dashboard provides basic log viewing capabilities.

## Deployment

The stack uses Docker configs to mount the configuration files. The configuration files (`prometheus.yml`, `alert.rules`, `loki.yml`, and `promtail.yml`) are stored in the same directory as the Docker Compose file and are automatically mounted when the stack is deployed.

No additional setup is required before deployment.

## Security Considerations

- Change the default Grafana admin password
- Consider setting up a reverse proxy with HTTPS
- Restrict access to the monitoring services using network rules

## Troubleshooting

- **Prometheus not scraping targets**: Check the Prometheus targets page at http://your-server-ip:9090/targets
- **Grafana can't connect to Prometheus**: Verify the data source URL is correct
- **Missing container metrics**: Ensure cAdvisor has access to Docker socket
- **Loki not receiving logs**: Check Promtail logs and ensure it has access to log directories
- **Missing logs in Grafana**: Verify Loki data source configuration and LogQL queries
