### Accessing Portainer
1. Navigate to http://your_server_ip:9000
2. Create an admin account on first login
3. Connect to the local Docker environment

### Restarting Portainer
Portainer may time out for security purposes after periods of inactivity. To restart it:

```bash
# SSH into the server
ssh root@your_server_ip

# Use the provided restart script
/usr/local/bin/restart-portainer.sh
```

Or you can manually restart the service:

```bash
docker service update --force portainer_portainer
```