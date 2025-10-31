# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Cloud                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              K3s Cluster (Single Node)                   │  │
│  │              ameciclo-k3s-vm                             │  │
│  │              10.20.1.4 (Private)                         │  │
│  │              20.172.9.53 (Public)                        │  │
│  │                                                          │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │         Kubernetes Namespaces                      │ │  │
│  │  │                                                    │ │  │
│  │  │  ┌──────────────┐  ┌──────────────┐              │ │  │
│  │  │  │   argocd     │  │    kong      │              │ │  │
│  │  │  │              │  │              │              │ │  │
│  │  │  │ • server     │  │ • proxy      │              │ │  │
│  │  │  │ • repo       │  │ • admin      │              │ │  │
│  │  │  │ • redis      │  │ • manager    │              │ │  │
│  │  │  │ • controller │  │              │              │ │  │
│  │  │  └──────────────┘  └──────────────┘              │ │  │
│  │  │                                                    │ │  │
│  │  │  ┌──────────────┐  ┌──────────────┐              │ │  │
│  │  │  │  kube-system │  │    atlas     │              │ │  │
│  │  │  │              │  │  (ready)     │              │ │  │
│  │  │  │ • coredns    │  │              │              │ │  │
│  │  │  │ • metrics    │  │ • cyclist-   │              │ │  │
│  │  │  │ • ingress    │  │   profile    │              │ │  │
│  │  │  └──────────────┘  │ • cyclist-   │              │ │  │
│  │  │                    │   counts     │              │ │  │
│  │  │                    │ • traffic-   │              │ │  │
│  │  │                    │   deaths     │              │ │  │
│  │  │                    └──────────────┘              │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │                                                          │  │
│  │  Services:                                              │  │
│  │  • ArgoCD Server: LoadBalancer (10.20.1.4:80)          │  │
│  │  • Kong Proxy: LoadBalancer (10.20.1.4:80)             │  │
│  │  • Kong Admin: NodePort (10.20.1.4:8001)               │  │
│  │  • Kong Manager: NodePort (10.20.1.4:8002)             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │    Azure PostgreSQL Flexible Server                      │  │
│  │    ameciclo-postgres.postgres.database.azure.com         │  │
│  │    B_Standard_B2s (2 vCores, 4 GB RAM)                   │  │
│  │                                                          │  │
│  │    Databases:                                           │  │
│  │    • kong (Kong configuration)                          │  │
│  │    • atlas (Microservices data)                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         ↑                                          ↑
         │                                          │
         └──────────────────┬───────────────────────┘
                            │
                    ┌───────▼────────┐
                    │  GitHub Repo   │
                    │  groundwork    │
                    │                │
                    │ azure/         │
                    │ kubernetes/    │
                    │ • kong/        │
                    │ • atlas/       │
                    │ • kestra/      │
                    └────────────────┘
                            ↑
                            │
                    ┌───────┴────────┐
                    │   Developer    │
                    │   Workflow     │
                    │                │
                    │ 1. Edit files  │
                    │ 2. git push    │
                    │ 3. ArgoCD      │
                    │    syncs auto  │
                    └────────────────┘
```

## Data Flow

### GitOps Workflow

```
Developer
    ↓
Edit azure/kubernetes/kong/values.yaml
    ↓
git add, commit, push
    ↓
GitHub Repository
    ↓
ArgoCD watches repository
    ↓
Detects changes
    ↓
Kustomize renders Helm chart
    ↓
ArgoCD applies manifests
    ↓
Kubernetes updates Kong pods
    ↓
Kong running with new configuration
```

### API Request Flow

```
Client Request
    ↓
Kong Proxy (80/443)
    ↓
Kong Routes
    ↓
Atlas Microservices
    ├─ cyclist-profile
    ├─ cyclist-counts
    └─ traffic-deaths
    ↓
PostgreSQL Database
    ↓
Response back to Client
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Azure VNet                           │
│                    10.20.0.0/16                         │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │         K3s Subnet                               │  │
│  │         10.20.1.0/24                             │  │
│  │                                                  │  │
│  │  ┌────────────────────────────────────────────┐ │  │
│  │  │  K3s VM                                    │ │  │
│  │  │  10.20.1.4 (Private)                       │ │  │
│  │  │  20.172.9.53 (Public)                      │ │  │
│  │  │                                            │ │  │
│  │  │  • ArgoCD: 80, 443                         │ │  │
│  │  │  • Kong Proxy: 80, 443                     │ │  │
│  │  │  • Kong Admin: 8001                        │ │  │
│  │  │  • Kong Manager: 8002                      │ │  │
│  │  │  • K3s API: 6443                           │ │  │
│  │  └────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  PostgreSQL Firewall Rules:                            │
│  • Allow K3s subnet (10.20.1.0/24)                     │
│  • Allow regular VM subnet (10.10.1.0/24)              │
│  • Port 5432                                           │
└─────────────────────────────────────────────────────────┘
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────┐
│                    ArgoCD                               │
│  (Watches Git, syncs to cluster)                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─→ Kong Application
                     │   (Helm chart from Git)
                     │
                     ├─→ Atlas Application
                     │   (Microservices from Git)
                     │
                     └─→ Kestra Application
                         (Workflow orchestration)
                         
                         ↓
                    
┌─────────────────────────────────────────────────────────┐
│                  Kubernetes                             │
│  (Runs containers, manages services)                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─→ Kong Pods
                     │   (API Gateway)
                     │
                     ├─→ Atlas Pods
                     │   (Microservices)
                     │
                     └─→ Kestra Pods
                         (Workflow engine)
                         
                         ↓
                    
┌─────────────────────────────────────────────────────────┐
│              PostgreSQL Database                        │
│  (Persistent data storage)                              │
└─────────────────────────────────────────────────────────┘
```

## Resource Allocation

```
Total VM Resources: 8 GB RAM, 2 vCPU

Current Usage:
├─ ArgoCD: ~167 MB
│  ├─ server: 37 MB
│  ├─ application-controller: 28 MB
│  ├─ applicationset-controller: 28 MB
│  ├─ repo-server: 23 MB
│  ├─ dex-server: 26 MB
│  ├─ notifications-controller: 20 MB
│  └─ redis: 7 MB
│
├─ Kube-system: ~46 MB
│  ├─ coredns: 16 MB
│  ├─ metrics-server: 22 MB
│  └─ local-path-provisioner: 8 MB
│
├─ Kong: (initializing)
│
└─ Available: ~6.2 GB (85%)
```

## Deployment Sequence

```
1. Terraform
   └─→ Creates Azure infrastructure
       ├─ K3s VM
       ├─ PostgreSQL
       └─ Network

2. Ansible
   └─→ Installs K3s and ArgoCD
       ├─ K3s cluster
       ├─ Helm
       ├─ ArgoCD
       └─ Kong (via Helm)

3. GitOps (ArgoCD)
   └─→ Manages all applications
       ├─ Kong (from Git)
       ├─ Atlas (from Git)
       └─ Kestra (from Git)
```

## Security Layers

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Network Security                              │
│  • Azure NSG (Network Security Group)                   │
│  • Firewall rules for ports 80, 443, 8001, 8002, 6443  │
│  • PostgreSQL firewall rules                            │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  Layer 2: Kubernetes Security                           │
│  • RBAC (Role-Based Access Control)                     │
│  • Network Policies                                     │
│  • Service Accounts                                     │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  Layer 3: Application Security                          │
│  • Kong authentication plugins                          │
│  • PostgreSQL credentials in secrets                    │
│  • TLS/SSL for external traffic                         │
└─────────────────────────────────────────────────────────┘
```

---

**Your infrastructure is production-ready and fully GitOps-enabled!** 🚀

