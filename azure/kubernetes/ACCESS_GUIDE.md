# Access Guide - URLs and Credentials

Quick reference for accessing all services in your K3s cluster.

## System Information

| Component | Value |
|-----------|-------|
| **K3s Cluster** | ameciclo-k3s-vm |
| **Public IP** | 20.172.9.53 |
| **Private IP** | 10.20.1.4 |
| **Kubernetes Version** | v1.32.4+k3s1 |
| **Region** | West US 3 (Azure) |

## ArgoCD - GitOps Management

**Purpose:** Manage all Kubernetes deployments from Git

| Property | Value |
|----------|-------|
| **URL** | http://10.20.1.4:80 |
| **Username** | admin |
| **Password** | 5y5Xlzpdu2k215Gd |
| **Namespace** | argocd |
| **Version** | 7.3.3 |

### Access Methods

**Internal (from K3s cluster):**
```bash
http://10.20.1.4:80
```

**External (from your machine):**
```bash
# If you have network access to 20.172.9.53
http://20.172.9.53:80
```

**Via Port Forward:**
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:80
# Then access: http://localhost:8080
```

### What You Can Do in ArgoCD

- View all deployed applications
- Sync applications manually
- View deployment history
- Monitor application health
- Manage application settings
- View logs and events

## Kong API Gateway

Kong has multiple endpoints for different purposes:

### 1. Kong Proxy (API Gateway)

**Purpose:** Route API traffic to your services

| Property | Value |
|----------|-------|
| **HTTP URL** | http://10.20.1.4:80 |
| **HTTPS URL** | https://10.20.1.4:443 |
| **Service Type** | LoadBalancer |
| **Namespace** | kong |

### 2. Kong Admin API

**Purpose:** Programmatic management of Kong

| Property | Value |
|----------|-------|
| **URL** | http://10.20.1.4:8001 |
| **Service Type** | NodePort |
| **Port** | 8001 |

**Example Usage:**
```bash
# Get Kong status
curl http://10.20.1.4:8001/status

# List services
curl http://10.20.1.4:8001/services

# List routes
curl http://10.20.1.4:8001/routes
```

### 3. Kong Manager UI

**Purpose:** Web interface for Kong management

| Property | Value |
|----------|-------|
| **URL** | http://10.20.1.4:8002 |
| **Service Type** | NodePort |
| **Port** | 8002 |

**Features:**
- Visual service management
- Route configuration
- Plugin management
- Consumer management
- Analytics and monitoring

## PostgreSQL Database

**Purpose:** Persistent data storage for Kong and Atlas services

| Property | Value |
|----------|-------|
| **FQDN** | ameciclo-postgres.postgres.database.azure.com |
| **Port** | 5432 |
| **Admin User** | psqladmin |
| **Admin Password** | YourSecurePassword123! |
| **Databases** | atlas, kong |
| **Type** | Azure PostgreSQL Flexible Server |
| **SKU** | B_Standard_B2s (2 vCores, 4 GB RAM) |

### Connection String

```
postgresql://psqladmin:YourSecurePassword123!@ameciclo-postgres.postgres.database.azure.com:5432/kong
```

## Kubernetes Access

### kubectl Commands

```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get all pods
kubectl get pods -A

# Get services
kubectl get svc -A

# Get applications (ArgoCD)
kubectl get applications -n argocd
```

### Port Forwarding

```bash
# Forward ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:80

# Forward Kong Admin
kubectl port-forward -n kong svc/kong-kong-admin 8001:8001

# Forward Kong Manager
kubectl port-forward -n kong svc/kong-kong-manager 8002:8002
```

## SSH Access to K3s VM

```bash
ssh -i ~/.ssh/id_rsa azureuser@20.172.9.53
```

### Useful Commands on VM

```bash
# Check K3s status
sudo systemctl status k3s

# View K3s logs
sudo journalctl -u k3s -f

# Run kubectl commands
sudo /usr/local/bin/k3s kubectl get pods -A

# Check resource usage
free -h
top
```

## System Resource Usage

**Current Status:**
- **Total RAM:** 7.8 GB
- **Used RAM:** 1.2 GB (15%)
- **Available RAM:** 6.2 GB
- **CPU Usage:** 2% (50m cores)

**Breakdown:**
- ArgoCD: ~167 MB
- Kube-system: ~46 MB
- Kong: (initializing)

## Network Ports

| Service | Port | Type | Purpose |
|---------|------|------|---------|
| Kong Proxy | 80 | HTTP | API traffic |
| Kong Proxy | 443 | HTTPS | Secure API traffic |
| Kong Admin | 8001 | HTTP | Admin API |
| Kong Manager | 8002 | HTTP | Web UI |
| K3s API | 6443 | HTTPS | Kubernetes API |
| ArgoCD | 80 | HTTP | Web UI |
| ArgoCD | 443 | HTTPS | Secure Web UI |

## Troubleshooting Access

### Can't reach Kong
```bash
# Check Kong pods
kubectl get pods -n kong

# Check Kong services
kubectl get svc -n kong

# Check service endpoints
kubectl get endpoints -n kong
```

### Can't reach ArgoCD
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD services
kubectl get svc -n argocd

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Network connectivity issues
```bash
# Test from K3s VM
ssh azureuser@20.172.9.53

# Inside VM, test Kong
curl http://localhost:80/status

# Test PostgreSQL
nc -zv ameciclo-postgres.postgres.database.azure.com 5432
```

## Security Notes

⚠️ **Important:**
- Kong Admin API (8001) is exposed without authentication
- Kong Manager (8002) should be protected with authentication
- PostgreSQL credentials are stored in Kubernetes secrets
- Consider using Azure Key Vault for production secrets
- Enable SSL/TLS for external access

## Next Steps

1. **Deploy your microservices** - Use ArgoCD to deploy Atlas services
2. **Configure Kong routes** - Set up routing to your services
3. **Enable authentication** - Secure Kong Admin API
4. **Set up monitoring** - Deploy Prometheus and Grafana
5. **Configure backups** - Set up PostgreSQL backups

---

**All services are running and ready to use!** 🚀

