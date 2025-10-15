# Kong Gateway Configuration for Atlas Services

This guide explains how to configure Kong Gateway to route traffic to Atlas services.

## Prerequisites

- Kong Gateway deployed and running
- Atlas stack deployed and running
- Both stacks connected to the same network (`kong-gateway_kong-net`)
- `curl` and `jq` installed for manual configuration

## Quick Setup

### Option 1: Automated Configuration (Recommended)

```bash
chmod +x stacks/kong/atlas-routes.sh
./stacks/kong/atlas-routes.sh
```

This script will automatically create all necessary services and routes.

### Option 2: Manual Configuration via Kong Admin API

#### 1. Create Cyclist Profile Service

```bash
curl -X POST http://localhost:8001/services \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cyclist-profile",
    "url": "http://atlas-cyclist-profile:3000",
    "tags": ["atlas", "api"]
  }'
```

#### 2. Create Cyclist Profile Route

```bash
curl -X POST http://localhost:8001/services/cyclist-profile/routes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cyclist-profile-route",
    "paths": ["/api/cyclist-profile"],
    "strip_path": true,
    "tags": ["atlas", "api"]
  }'
```

#### 3. Create Documentation Service

```bash
curl -X POST http://localhost:8001/services \
  -H "Content-Type: application/json" \
  -d '{
    "name": "atlas-docs",
    "url": "http://atlas-docs:80",
    "tags": ["atlas", "docs"]
  }'
```

#### 4. Create Documentation Route

```bash
curl -X POST http://localhost:8001/services/atlas-docs/routes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "docs-route",
    "paths": ["/docs"],
    "strip_path": false,
    "tags": ["atlas", "docs"]
  }'
```

## Service Configuration Details

### Cyclist Profile Service

- **Service Name**: `cyclist-profile`
- **Backend URL**: `http://atlas-cyclist-profile:3000`
- **Route Path**: `/api/cyclist-profile`
- **Strip Path**: `true` (removes `/api/cyclist-profile` prefix before forwarding)
- **Health Check**: `GET /health`

### Documentation Service (Static React App)

- **Service Name**: `atlas-docs`
- **Backend URL**: `http://atlas-docs:80`
- **Route Path**: `/docs`
- **Strip Path**: `false` (preserves `/docs` prefix)
- **Server**: Nginx serving static React application
- **Health Check**: `GET /index.html`

## Verification

### List All Atlas Services

```bash
curl http://localhost:8001/services | jq '.data[] | select(.tags[] | contains("atlas"))'
```

### List All Atlas Routes

```bash
curl http://localhost:8001/routes | jq '.data[] | select(.tags[] | contains("atlas"))'
```

### Test Cyclist Profile API

```bash
curl http://localhost/api/cyclist-profile/health
```

### Test Documentation

```bash
curl http://localhost/docs
```

## Adding Plugins (Optional)

### Rate Limiting

```bash
curl -X POST http://localhost:8001/services/cyclist-profile/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "rate-limiting",
    "config": {
      "minute": 100,
      "policy": "local"
    }
  }'
```

### Authentication (Basic Auth)

```bash
curl -X POST http://localhost:8001/services/cyclist-profile/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "basic-auth"
  }'
```

### CORS

```bash
curl -X POST http://localhost:8001/services/cyclist-profile/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cors",
    "config": {
      "origins": ["*"],
      "methods": ["GET", "POST", "PUT", "DELETE", "PATCH"],
      "headers": ["Accept", "Accept-Version", "Content-Length", "Content-MD5", "Content-Type", "Date"],
      "exposed_headers": ["X-Auth-Token"],
      "credentials": true,
      "max_age": 3600
    }
  }'
```

## Kong Manager UI

Access Kong Manager at: `http://localhost:8002`

Default credentials (if configured):
- Username: `admin`
- Password: Check your Kong environment variables

## Troubleshooting

### Services Not Accessible

1. Verify Atlas services are running:
   ```bash
   docker ps | grep atlas
   ```

2. Check Kong network connectivity:
   ```bash
   docker network inspect kong-gateway_kong-net
   ```

3. Test service connectivity from Kong container:
   ```bash
   docker exec kong curl http://atlas-cyclist-profile:3000/health
   ```

### Route Not Working

1. Verify route exists:
   ```bash
   curl http://localhost:8001/routes
   ```

2. Check service health:
   ```bash
   curl http://localhost:8001/services/cyclist-profile/health
   ```

3. View Kong logs:
   ```bash
   docker logs kong
   ```

## Environment Variables

Configure these in your Kong stack `.env` file:

```env
KONG_DATABASE=postgres
KONG_PG_HOST=your-db-host.example.com
KONG_PG_PORT=25060
KONG_PG_USER=doadmin
KONG_PG_DATABASE=kong
KONG_PG_PASSWORD=your-password
KONG_PG_SSL=on
KONG_PROXY_LISTEN=0.0.0.0:80, 0.0.0.0:443 ssl
KONG_ADMIN_LISTEN=0.0.0.0:8001
KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002
KONG_LOG_LEVEL=notice
```

## References

- [Kong Admin API Documentation](https://docs.konghq.com/gateway/latest/admin-api/)
- [Kong Services Documentation](https://docs.konghq.com/gateway/latest/admin-api/#service-object)
- [Kong Routes Documentation](https://docs.konghq.com/gateway/latest/admin-api/#route-object)

