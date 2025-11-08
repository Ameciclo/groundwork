# What is an Ingress?

## Simple Explanation

**Ingress** = A traffic controller that routes HTTP/HTTPS requests to your services

Think of it like a **receptionist** at a hotel:
- Requests come in (guests arrive)
- Receptionist looks at the request (checks the domain/path)
- Routes it to the right service (sends guest to right room)

## Docker Compose Comparison

### Docker Compose (Simple)
```yaml
services:
  web:
    image: nginx
    ports:
      - "80:80"      # Expose port 80 on the host
      - "443:443"    # Expose port 443 on the host
```

**Problem:** You can only run ONE service on port 80!

### Kubernetes (Better)
```yaml
# Service (internal networking)
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  ports:
    - port: 80
  selector:
    app: web

# Ingress (external routing)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

**Benefit:** Multiple services on the same port 80!

## Real-World Example: Your Groundwork Setup

You have THREE services running:
- `atlas` (traffic-deaths API)
- `strapi` (CMS)
- `traefik` (reverse proxy)

### Without Ingress (Docker Compose way)
```
Port 3000 → atlas
Port 3001 → strapi
Port 3002 → traefik
```

Users would need to remember: `atlas.example.com:3000`, `strapi.example.com:3001`

### With Ingress (Kubernetes way)
```
obitos.atlas.az.ameciclo.org → atlas service
docs.atlas.az.ameciclo.org   → strapi service
```

Users just use domain names, Ingress routes them!

## How Ingress Works

```
Internet Request
    ↓
Ingress Controller (Traefik in your case)
    ↓
Reads Ingress rules
    ↓
Matches domain/path
    ↓
Routes to correct Service
    ↓
Service load-balances to Pods
    ↓
Response sent back
```

## Your Actual Ingress Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-deaths
  namespace: atlas
  annotations:
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  rules:
  - host: obitos.atlas.az.ameciclo.org
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: traffic-deaths
            port:
              number: 3003
```

**What this does:**
1. Listens for requests to `obitos.atlas.az.ameciclo.org`
2. Routes them to `traffic-deaths` service on port 3003
3. Automatically handles TLS (HTTPS) with Let's Encrypt
4. Traefik controller makes it all work

## Key Ingress Features

### 1. Domain-based Routing
```yaml
rules:
- host: api.example.com
  http:
    paths:
    - backend:
        service:
          name: api-service
- host: web.example.com
  http:
    paths:
    - backend:
        service:
          name: web-service
```

### 2. Path-based Routing
```yaml
rules:
- host: example.com
  http:
    paths:
    - path: /api
      backend:
        service:
          name: api-service
    - path: /web
      backend:
        service:
          name: web-service
```

### 3. TLS/HTTPS
```yaml
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
```

## Ingress vs Service

| Feature | Service | Ingress |
|---------|---------|---------|
| **Purpose** | Internal networking | External routing |
| **Layer** | Layer 4 (TCP/UDP) | Layer 7 (HTTP/HTTPS) |
| **Domains** | No | Yes |
| **TLS** | No | Yes |
| **Paths** | No | Yes |
| **Load balancing** | Yes | Yes |

## Ingress Controllers

An **Ingress Controller** is software that reads Ingress rules and makes them work.

Common controllers:
- **Traefik** (what you're using) ✅
- **Nginx Ingress Controller**
- **HAProxy**
- **AWS ALB**

Your Traefik is the Ingress Controller!

## In Your Groundwork Setup

```
Internet
    ↓
Traefik (Ingress Controller)
    ↓
Reads Ingress rules:
  - obitos.atlas.az.ameciclo.org → traffic-deaths service
  - docs.atlas.az.ameciclo.org → atlas-docs service
    ↓
Routes to correct service
    ↓
Service load-balances to pods
    ↓
Response sent back
```

## Key Takeaway

**Ingress = Smart traffic router for Kubernetes**

It lets you:
- ✅ Use domain names instead of ports
- ✅ Route multiple services on same port
- ✅ Handle HTTPS/TLS automatically
- ✅ Route based on paths
- ✅ Manage certificates automatically

Without Ingress, you'd need to expose each service on a different port (like Docker Compose).

