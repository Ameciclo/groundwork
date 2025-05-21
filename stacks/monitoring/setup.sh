#!/bin/bash
# Setup script for monitoring stack

# Create volumes for configuration files
echo "Creating Docker volumes for configuration..."
docker volume create monitoring_prometheus_config
docker volume create monitoring_alert_rules

# Copy configuration files to volumes
echo "Copying configuration files to volumes..."
docker run --rm -v $(pwd)/prometheus.yml:/src/prometheus.yml -v monitoring_prometheus_config:/dest alpine cp /src/prometheus.yml /dest/
docker run --rm -v $(pwd)/alert.rules:/src/alert.rules -v monitoring_alert_rules:/dest alpine cp /src/alert.rules /dest/

echo "Setup complete! You can now deploy the monitoring stack in Portainer."
echo "Remember to set your environment variables in Portainer before deployment."
