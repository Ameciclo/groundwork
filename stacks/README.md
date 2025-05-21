# Docker Swarm Stacks

This directory contains Docker Swarm stack definitions for deployment with Portainer.

## Directory Structure

- `kong/` - Kong API Gateway stack
- Add more services as needed

Note: Portainer itself is deployed via Ansible during initial provisioning and not stored here.

## Deployment with Portainer

### Using Git Integration

1. In Portainer, go to Stacks > Add stack
2. Select "Git repository"
3. Enter your repository URL
4. Specify the path to the stack file (e.g., `stacks/kong/docker-compose.yml`)
5. Add your environment variables in the UI
6. Deploy the stack

### Environment Variables

Each stack directory contains:
- `docker-compose.yml` - The stack definition
- `.env.example` - Example environment variables (DO NOT put real secrets here)

Real secrets should be entered directly in Portainer's UI.

### Auto Updates

To enable automatic updates when your repository changes:

1. In Portainer, edit your stack
2. Enable "Auto update"
3. Configure the update interval or webhook

## Security Notes

- Never commit real secrets to this repository
- Use `.env.example` files for documentation only
- Enter actual secrets in Portainer's UI
- Consider using Docker secrets for production deployments
