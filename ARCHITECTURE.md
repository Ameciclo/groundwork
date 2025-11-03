# Ameciclo Infrastructure Architecture

## Overview

This document describes the complete infrastructure architecture for Ameciclo, including both Docker Swarm (DigitalOcean) and Kubernetes (Azure) deployments.

## Infrastructure Components

### 1. Docker Swarm (DigitalOcean)
- **Status**: Production
- **Services**:
  - Portainer (UI management)
  - Kong API Gateway (with PostgreSQL backend)
  - Other legacy services

### 2. Kubernetes Cluster (Azure)
- **Status**: Production
- **Distribution**: K3s v1.32.4+k3s1
- **VM**: Standard_B2as_v2 (Ubuntu 22.04 LTS)
- **Network**: Private VPC with Tailscale VPN access

## K3s Cluster Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Azure K3s Cluster                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Bootstrap Layer (Manual/Ansible):                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 1. K3s (Kubernetes)                             │   │
│  │    - Disabled: Traefik, ServiceLB               │   │
│  │    - Enabled: Ingress Controller (K3s default)  │   │
│  │                                                 │   │
│  │ 2. Tailscale Operator                           │   │
│  │    - Provides VPN access to cluster             │   │
│  │    - Ingress class: tailscale                   │   │
│  │    - Exposes services via Tailscale DNS         │   │
│  │                                                 │   │
│  │ 3. ArgoCD                                       │   │
│  │    - GitOps continuous deployment               │   │
│  │    - Accessible via: argocd.armadillo-hamal.ts.net │
│  │    - Manages all other services                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  GitOps Managed Layer (ArgoCD):                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Kong API Gateway                                │   │
│  │ - Proxy: kong-kong-kong-proxy.armadillo-hamal.ts.net │
│  │ - Admin: kong-admin.armadillo-hamal.ts.net      │   │
│  │ - Manager: kong-manager.armadillo-hamal.ts.net  │   │
│  │ - Database: PostgreSQL (Azure Private Endpoint) │   │
│  │                                                 │   │
│  │ Other Services (to be deployed):                │   │
│  │ - Kestra (workflow orchestration)               │   │
│  │ - Metabase (analytics)                          │   │
│  │ - Custom applications                           │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Deployment Strategy

### Bootstrap Phase (One-time, Ansible)
1. **K3s Installation**
   - Lightweight Kubernetes distribution
   - Disabled Traefik (we use Tailscale Ingress)
   - Disabled ServiceLB (we use Tailscale LoadBalancer)

2. **Tailscale Operator**
   - Provides VPN access to cluster
   - Ingress controller for private access
   - OAuth credentials passed at deployment time

3. **ArgoCD**
   - GitOps continuous deployment
   - Manages all other services
   - Accessible via Tailscale Ingress

### GitOps Phase (Continuous, ArgoCD)
All services are managed by ArgoCD through Git:
- Kong API Gateway
- Custom applications
- Infrastructure components

## Service Access

### Public Access
- **Kong Proxy**: `kong-kong-kong-proxy.armadillo-hamal.ts.net` (Tailscale only)
  - Port 80 (HTTP) → 8000
  - Port 443 (HTTPS) → 8443

### Private Access (Tailscale VPN)
- **ArgoCD**: `https://argocd.armadillo-hamal.ts.net`
- **Kong Admin API**: `https://kong-admin.armadillo-hamal.ts.net`
- **Kong Manager GUI**: `https://kong-manager.armadillo-hamal.ts.net`

## Database Architecture

### PostgreSQL (Azure)
- **Type**: Flexible Server
- **Version**: PostgreSQL 16
- **SKU**: B_Standard_B2s
- **Access**: Private endpoint (VPC only)
- **Databases**:
  - `kong` - Kong API Gateway configuration

### Connection
- **From K3s**: Private VPC connection
- **Hostname**: `ameciclo-postgres.privatelink.postgres.database.azure.com`
- **Port**: 5432
- **SSL**: Enabled

## GitOps Workflow

```
┌──────────────────┐
│  Git Repository  │
│  (groundwork)    │
└────────┬─────────┘
         │
         │ Push changes
         ↓
┌──────────────────────────────────┐
│  ArgoCD                          │
│  - Watches Git repository        │
│  - Detects changes               │
│  - Applies manifests to cluster  │
└────────┬─────────────────────────┘
         │
         ↓
┌──────────────────────────────────┐
│  K3s Cluster                     │
│  - Kong                          │
│  - Other services                │
│  - Infrastructure components     │
└──────────────────────────────────┘
```

## File Organization

```
groundwork/
├── ansible/
│   ├── k3s-bootstrap-playbook.yml      # Bootstrap K3s + Tailscale + ArgoCD
│   ├── K3S_BOOTSTRAP_GUIDE.md          # Setup instructions
│   └── k3s-azure-inventory.yml         # Ansible inventory
│
├── azure/
│   ├── kubernetes/
│   │   ├── kong/
│   │   │   ├── argocd-application.yaml # Kong deployment via ArgoCD
│   │   │   ├── service-admin.yaml      # Kong admin service
│   │   │   ├── ingress-admin.yaml      # Kong admin ingress
│   │   │   └── ingress-manager.yaml    # Kong manager ingress
│   │   │
│   │   └── argocd-tailscale-ingress.yaml # ArgoCD ingress
│   │
│   ├── k3s.tf                          # K3s VM infrastructure
│   ├── postgres.tf                     # PostgreSQL database
│   └── terraform.tfvars                # Terraform variables
│
└── ARCHITECTURE.md                     # This file
```

## Deployment Checklist

- [x] Azure infrastructure (Terraform)
- [x] K3s installation (Ansible)
- [x] Tailscale Operator deployment
- [x] ArgoCD deployment
- [x] Kong deployment via ArgoCD
- [x] Kong admin/manager access via Tailscale
- [ ] Additional services (Kestra, Metabase, etc.)
- [ ] Monitoring and logging
- [ ] Backup and disaster recovery

## Next Steps

1. **Deploy Additional Services**
   - Create ArgoCD Applications for other services
   - Store manifests in Git repository

2. **Configure Monitoring**
   - Deploy Prometheus for metrics
   - Deploy Grafana for visualization

3. **Setup Backup**
   - Configure PostgreSQL backups
   - Setup cluster state backups

4. **Security Hardening**
   - Enable RBAC policies
   - Configure network policies
   - Setup secrets management

## References

- [K3s Documentation](https://docs.k3s.io/)
- [Tailscale Operator](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kong API Gateway](https://docs.konghq.com/)

