# Kong API Gateway Stack (Environment Variables Approach)

This directory contains the Docker Swarm stack definition for Kong API Gateway.

## Configuration Approach

Kong is configured entirely using environment variables:

1. **Default Values**: Common settings have default values in the Docker Compose file
2. **Environment Variables**: All settings can be overridden through Portainer's environment variables UI

This approach provides several benefits:
- Works seamlessly with Portainer's Git-based deployment
- No need for separate configuration files
- Easy to override settings through Portainer's UI
- Sensitive information is kept separate from the code

## Files

- `docker-compose.yml`: The Docker Swarm stack definition with Kong configuration
- `.env.example`: Example environment variables (do not put real secrets here)

## Deployment with Portainer

1. In Portainer, go to Stacks > Add stack
2. Select "Git repository"
3. Enter your repository URL
4. Specify the path to this stack: `stacks/kong/docker-compose.yml`
5. Add your environment variables:
   - `KONG_PG_PASSWORD`: Your database password
   - `KONG_ADMIN_GUI_SESSION_SECRET`: A secure random string for session encryption

## Kong Manager Authentication

Kong Manager authentication is enabled in the `kong.conf` file:

```
admin_gui_auth = basic-auth
admin_gui_session_conf = { "secret":"PLACEHOLDER_SECRET", "storage":"kong", "cookie_secure":false }
```

After deploying Kong, you'll need to create an admin user:

```bash
# Create an admin user
curl -X POST http://your-kong-admin:8001/admins/ \
  -d username=admin \
  -d email=admin@example.com \
  -d password=your_password
```

## Customizing Kong

To modify Kong's configuration:

1. Edit the `kong.conf` file in this directory
2. Commit and push your changes
3. Update the stack in Portainer

For more information on Kong configuration options, see the [Kong documentation](https://docs.konghq.com/gateway/latest/reference/configuration/).
