# Kestra Workflow Orchestration

This directory contains a Docker Swarm stack for Kestra, an open-source data orchestration and scheduling platform.

## Configuration

This setup uses Kestra in "local" mode, which uses an embedded H2 database file for persistence. This approach provides:
- Persistence across container restarts
- No need for external database services
- Simplified deployment and maintenance

For production use with higher scalability, consider adding PostgreSQL and Elasticsearch.

## Components

- **Kestra Server**: The main application that runs workflows and provides the UI
- **Embedded H2 Database**: Stores metadata, flows, and execution history
- **Local Storage**: Used for task data and artifacts
- **Prometheus Integration**: Exposes metrics for monitoring

## Deployment with Portainer

1. In Portainer, go to Stacks > Add stack
2. Select "Git repository"
3. Enter your repository URL
4. Specify the path to this stack: `stacks/kestra/docker-compose.yml`
5. The `.env` file is already included in the repository
6. Deploy the stack

## Accessing Kestra

After deployment, you can access Kestra at:
- **URL**: http://your-server-ip:8082 (external port mapped to internal port 8080)
- **Default credentials**: admin / kestra (change these in the environment variables)

## Creating Your First Flow

1. Log in to Kestra
2. Go to "Namespaces" and create a new namespace (e.g., "examples")
3. Go to "Flows" and create a new flow:

```yaml
id: hello-world
namespace: examples
tasks:
  - id: hello
    type: io.kestra.core.tasks.log.Log
    message: Hello, World!
```

4. Save and run the flow

## Monitoring with Prometheus

Kestra exposes metrics at:
- **Metrics endpoint**: http://kestra:8080/metrics

To add Kestra to your Prometheus monitoring:

1. Edit `stacks/monitoring/prometheus.yml`
2. Add a new job for Kestra:

```yaml
- job_name: 'kestra'
  static_configs:
    - targets: ['kestra:8080']
```

3. Update your Prometheus configuration

## Installing Plugins

To add plugins to Kestra:

1. Download the plugin JAR file
2. Place it in a directory on your server
3. Mount that directory to `/app/plugins` in the Kestra container

## Limitations of Local Mode

While the local mode with embedded H2 database provides persistence, it has some limitations:
- Limited scalability (single instance only)
- No high availability features
- Performance may degrade with very large datasets
- No built-in backup/restore functionality (manual volume backups required)

For production use with higher demands, consider setting up:
- PostgreSQL for metadata storage
- Elasticsearch for indexing and searching
- Kafka for the queue system

## Troubleshooting

If Kestra fails to start:

1. **Check container logs**:
   ```bash
   docker service logs kestra_kestra
   ```

2. **Memory issues**:
   - The container is configured with modest memory settings (512MB max)
   - If your server has limited resources, you may need to reduce this further

3. **Port conflicts**:
   - Kestra runs on port 8080 internally
   - We map this to port 8082 externally
   - Make sure port 8082 is not used by another service

4. **Configuration issues**:
   - Check that the configuration file is correctly mounted
   - Verify that the application.yml file has the correct settings
