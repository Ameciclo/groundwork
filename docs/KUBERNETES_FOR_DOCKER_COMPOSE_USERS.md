# Kubernetes for Docker Compose Users

## The Big Picture

**Docker Compose**: Runs containers on a single machine
**Kubernetes**: Runs containers across multiple machines (a cluster)

Think of it like this:
- **Docker Compose** = Managing a small restaurant kitchen
- **Kubernetes** = Managing a chain of restaurants across the city

## Key Concepts Mapping

### 1. Services

**Docker Compose:**
```yaml
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: web
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3  # Run 3 copies!
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:latest
        ports:
        - containerPort: 80
```

**Key Differences:**
- Kubernetes separates **Service** (networking) from **Deployment** (running containers)
- You specify **replicas** (how many copies to run)
- Kubernetes automatically restarts failed containers
- Kubernetes spreads containers across multiple machines

### 2. Volumes

**Docker Compose:**
```yaml
volumes:
  db_data:

services:
  db:
    image: postgres
    volumes:
      - db_data:/var/lib/postgresql/data
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
spec:
  serviceName: db
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres
        volumeMounts:
        - name: db-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: db-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### 3. Environment Variables

**Docker Compose:**
```yaml
services:
  app:
    image: myapp
    environment:
      DATABASE_URL: postgres://db:5432
      API_KEY: secret123
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: postgres://db:5432
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  API_KEY: secret123
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
```

## Core Kubernetes Objects

| Docker Compose | Kubernetes | Purpose |
|---|---|---|
| `services` | `Deployment` / `StatefulSet` | Run containers |
| `ports` | `Service` | Expose containers to network |
| `volumes` | `PersistentVolume` / `PersistentVolumeClaim` | Store data |
| `environment` | `ConfigMap` / `Secret` | Configuration |
| `networks` | `Namespace` | Isolation |
| `depends_on` | `initContainers` / `readinessProbe` | Startup order |

## Workflow Comparison

### Docker Compose
```bash
docker-compose up          # Start everything
docker-compose down        # Stop everything
docker-compose logs        # View logs
docker-compose ps          # See running containers
```

### Kubernetes
```bash
kubectl apply -f deployment.yaml   # Deploy
kubectl delete -f deployment.yaml  # Remove
kubectl logs pod-name              # View logs
kubectl get pods                   # See running pods
kubectl describe pod pod-name      # Detailed info
```

## Why Kubernetes is More Complex

1. **Distributed** - Containers can run on different machines
2. **Self-healing** - Automatically restarts failed containers
3. **Scaling** - Easy to run 1 or 1000 replicas
4. **Rolling updates** - Update without downtime
5. **Load balancing** - Automatic traffic distribution
6. **Storage** - Persistent data across machines

## Real-World Example: Your Groundwork Setup

**What you have:**
- 3 applications (atlas, strapi, traefik)
- Each with multiple replicas
- Persistent databases
- Secrets from Infisical
- Automatic TLS certificates
- Automatic deployments via ArgoCD

**In Docker Compose**, you'd need:
- One powerful machine
- Manual restarts if something fails
- Manual scaling
- Manual certificate management

**In Kubernetes**, you get:
- Automatic restarts ✅
- Automatic scaling ✅
- Automatic certificates ✅
- Automatic deployments ✅
- Works across multiple machines ✅

## Key Takeaways

1. **Kubernetes = Docker Compose on steroids**
2. **More powerful but more complex**
3. **Worth it for production systems**
4. **You define desired state, Kubernetes makes it happen**
5. **Everything is declarative (YAML files)**

## Next Steps

- Learn `kubectl` commands
- Understand Pods, Deployments, Services
- Practice with `kubectl apply` and `kubectl delete`
- Use tools like ArgoCD to manage deployments (like you're doing!)

