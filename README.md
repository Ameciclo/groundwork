# Groundwork - Ameciclo Infrastructure

Modern cloud infrastructure for Ameciclo using **Pulumi + Azure + Kubernetes**.

## 🚀 Quick Start

```bash
# 1. Deploy infrastructure
cd infrastructure/pulumi
npm install           # Install dependencies
pulumi stack init ameciclo/prod  # Initialize stack
pulumi up             # Deploy to Azure

# 2. Access your cluster
ssh azureuser@$(pulumi stack output k3sPublicIp)

# 3. Check applications
kubectl get applications -n argocd
```

## 🏗️ What Gets Deployed

### Infrastructure (Pulumi)
- **🌐 Azure Virtual Network** - Secure networking with K3s and database subnets
- **🗄️ PostgreSQL Flexible Server** - Private database (Standard_B2s) with 3 databases: strapi, atlas, zitadel
- **☸️ K3s Kubernetes Cluster** - Lightweight Kubernetes on Ubuntu 22.04 LTS (Standard_B2as_v2)
- **💾 Blob Storage** - Media, backups, and logs containers
- **🔒 Network Security** - Firewall rules, private DNS, and SSH-only access

### Bootstrap (Ansible)
- **K3s** - Kubernetes installation and configuration
- **Tailscale Operator** - VPN operator (bootstrap only)
- **ArgoCD** - GitOps deployment platform

### GitOps (ArgoCD)
- **Tailscale** - Ingress and subnet router configuration
- **Traefik** - Ingress controller v37.2.0 with Let's Encrypt
- **Monitoring** - Prometheus + Grafana for metrics and dashboards
- **Applications** - Strapi CMS, Atlas APIs, Zitadel Auth
- **Infrastructure** - Infisical secrets management

**💰 Cost**: ~$70-80/month for complete infrastructure

## 📁 Repository Structure

```
groundwork/
├── 🏗️  infrastructure/           # Infrastructure as Code
│   └── pulumi/                  # Pulumi (Azure infrastructure)
│       ├── index.ts             # Main infrastructure definition
│       ├── vm.ts                # K3s VM configuration
│       ├── scripts/             # Database setup scripts
│       └── esc/                 # Pulumi ESC environments
├── ☸️  kubernetes/               # Kubernetes manifests
│   ├── applications/            # Custom applications (Strapi, Atlas, Zitadel)
│   ├── infrastructure/          # Platform components (Traefik, ArgoCD)
│   └── argocd/                  # ArgoCD application definitions
└── 📚 docs/                     # Documentation & guides
```

## 📋 Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) v3.139.0+
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure account + Service Principal
- SSH key pair
- Pulumi Cloud account (for ESC environments)

## 🔧 Detailed Setup

<details>
<summary>Click to expand detailed setup instructions</summary>

### 1. Install Dependencies

```bash
cd infrastructure/pulumi
npm install
```

### 2. Configure Pulumi ESC Environment

```bash
# Create ESC environment
pulumi env init ameciclo/infrastructure-prod

# Edit environment (copy from infrastructure/pulumi/esc/prod.yaml)
pulumi env edit ameciclo/infrastructure-prod

# Update SSH public key in the environment
cat ~/.ssh/id_rsa.pub  # Copy this value
```

### 3. Configure Azure Authentication

```bash
# Login to Azure
az login

# Pulumi will auto-detect Azure credentials from Azure CLI
```

### 4. Set Stack Configuration

```bash
# Set SSH key (if not using ESC)
pulumi config set --secret adminSshPublicKey "$(cat ~/.ssh/id_rsa.pub)"
```

### 5. Deploy

```bash
pulumi preview  # Review what will be created
pulumi up      # Deploy infrastructure
```

### 6. Create Database Users

```bash
# SSH into the K3s VM
ssh azureuser@$(pulumi stack output k3sPublicIp)

# Copy and run the database setup script
# (Script is automatically copied during deployment)
POSTGRES_ADMIN_PASSWORD='<from-pulumi-output>' ./create-database-users.sh
```

</details>

## 🏗️ Infrastructure Details

<details>
<summary>Azure Resources (click to expand)</summary>

### 🌐 Virtual Network

- **Address Space**: `10.10.0.0/16`
- **K3s Subnet**: `10.10.1.0/24`
- **Database Subnet**: `10.10.2.0/24`

### 🗄️ PostgreSQL Flexible Server

- **Tier**: Standard_B2s (2 vCores, 4GB RAM)
- **Storage**: 32GB, 7-day backups
- **Networking**: Private only (VNet access)
- **Databases**: `strapi`, `atlas`, `zitadel`
- **Users**: Auto-generated with secure passwords

### ☸️ K3s Cluster

- **VM Size**: Standard_B2as_v2 (2 vCPUs, 8GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 30GB Premium SSD
- **IP**: Static private + public IP
- **K3s Version**: Latest stable

### 💾 Blob Storage

- **Type**: Standard LRS (Locally Redundant Storage)
- **Containers**: `media`, `backups`, `logs`
- **Access**: Private with VNet integration
- **TLS**: Minimum version 1.2

</details>

## 📱 Applications

| Application | Purpose              | URL Pattern              |
| ----------- | -------------------- | ------------------------ |
| **Strapi**  | Headless CMS         | `strapi.az.ameciclo.org` |
| **Atlas**   | Traffic Data APIs    | `atlas.az.ameciclo.org`  |
| **Zitadel** | Identity & Auth      | `auth.az.ameciclo.org`   |
| **Traefik** | Ingress Controller   | Auto HTTPS               |
| **ArgoCD**  | GitOps Deployment    | Internal                 |
| **Infisical** | Secrets Management | Internal                 |

### 🔄 GitOps Workflow

1. **Push** code changes to this repository
2. **ArgoCD** detects changes automatically
3. **Deploys** applications to Kubernetes cluster
4. **Notifies** via Telegram on success/failure

## 💰 Cost Breakdown

| Service    | Tier             | Monthly Cost |
| ---------- | ---------------- | ------------ |
| PostgreSQL | Standard_B2s     | ~$24         |
| VM (K3s)   | Standard_B2as_v2 | ~$38         |
| Storage    | Standard LRS     | ~$2          |
| Networking | Standard         | ~$8          |
| **Total**  |                  | **~$72**     |

*Costs are estimates for West US 3 region. Actual costs may vary.*

## 🛠️ Management Commands

```bash
# Infrastructure
cd infrastructure/pulumi
pulumi stack output                              # View outputs
pulumi stack output postgresqlAdminPassword --show-secrets  # Get DB password
pulumi up                                        # Update infrastructure
pulumi destroy                                   # ⚠️ Destroy everything

# Access K3s VM
ssh azureuser@$(pulumi stack output k3sPublicIp)

# Kubernetes (from VM)
kubectl get applications -n argocd               # View ArgoCD apps
kubectl get pods -A                              # Check all pods
kubectl logs -n <namespace> <pod-name>           # View logs
btop                                             # System monitor
```

## 🔒 Security Features

- ✅ **Private Database** - PostgreSQL only accessible from VNet
- ✅ **SSH Key Auth** - No password authentication
- ✅ **Network Security Groups** - Restricted port access (SSH, HTTP, HTTPS only)
- ✅ **Secret Management** - Pulumi ESC + Infisical
- ✅ **Auto HTTPS** - Traefik + Let's Encrypt
- ✅ **Encrypted Secrets** - All passwords encrypted in Pulumi state
- ✅ **Private DNS** - Internal DNS resolution for database

## 📚 Documentation

- [📖 Detailed Docs](docs/) - Kubernetes guides and concepts
- [🏗️ Infrastructure Setup](infrastructure/pulumi/README.md) - Pulumi details
- [☸️ Application Configs](kubernetes/) - Kubernetes manifests

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Test in a separate Pulumi stack
4. Submit a pull request

---

**Built with ❤️ by Ameciclo** | [Website](https://ameciclo.org) | [GitHub](https://github.com/Ameciclo)
