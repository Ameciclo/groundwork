# Groundwork - Ameciclo Infrastructure

Modern cloud infrastructure for Ameciclo using **Pulumi + Azure + Kubernetes**.

## 🚀 Quick Start

```bash
# 1. Deploy infrastructure
cd pulumi/infrastructure
./scripts/setup.sh    # Configure credentials
pulumi up             # Deploy to Azure

# 2. Access your cluster
ssh azureuser@$(pulumi stack output k3sPublicIp)

# 3. Check applications
kubectl get applications -n argocd
```

## 🏗️ What Gets Deployed

- **🌐 Azure Virtual Network** - Secure networking with K3s and database subnets
- **🗄️ PostgreSQL Database** - Managed database with private connectivity
- **☸️ K3s Kubernetes Cluster** - Lightweight Kubernetes on Ubuntu 22.04 LTS
- **🔒 Network Security** - Firewall rules and private DNS
- **📱 Applications** - Strapi CMS, Atlas APIs, Traefik ingress, ArgoCD GitOps

**💰 Cost**: ~$80/month for complete infrastructure

## 📁 Repository Structure

```
groundwork/
├── 🏗️  pulumi/infrastructure/    # Azure infrastructure (Pulumi TypeScript)
├── ⚙️  pulumi/scripts/           # Setup scripts & Ansible playbooks
├── ☸️  helm/                     # Kubernetes applications
│   ├── charts/                  # Strapi, Atlas, Traefik, ArgoCD
│   └── environments/            # Production configurations
└── 📚 docs/                     # Documentation & guides
```

## 📋 Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/)
- Azure account + Service Principal
- SSH key pair

## 🔧 Detailed Setup

<details>
<summary>Click to expand detailed setup instructions</summary>

### 1. Install Dependencies
```bash
cd pulumi/infrastructure
npm install
```

### 2. Configure Azure Credentials
```bash
# Set Azure authentication
pulumi config set azure-native:subscriptionId --secret YOUR_SUBSCRIPTION_ID
pulumi config set azure-native:clientId --secret YOUR_CLIENT_ID
pulumi config set azure-native:clientSecret --secret YOUR_CLIENT_SECRET
pulumi config set azure-native:tenantId --secret YOUR_TENANT_ID

# Set database credentials
pulumi config set postgresqlAdminUsername --secret YOUR_DB_USERNAME
pulumi config set postgresqlAdminPassword --secret YOUR_DB_PASSWORD

# Set SSH key
pulumi config set adminSshPublicKey --secret "$(cat ~/.ssh/id_rsa.pub)"
```

### 3. Deploy
```bash
pulumi preview  # Review what will be created
pulumi up      # Deploy infrastructure
```

</details>

## 🏗️ Infrastructure Details

<details>
<summary>Azure Resources (click to expand)</summary>

### 🌐 Virtual Network
- **Address Space**: `10.10.0.0/16`
- **K3s Subnet**: `10.10.1.0/24`
- **Database Subnet**: `10.10.2.0/24`

### 🗄️ PostgreSQL Database
- **Tier**: Standard_B2s (2 vCores, 4GB RAM)
- **Storage**: 32GB, 7-day backups
- **Networking**: Private only
- **Databases**: `atlas`, `kong`

### ☸️ K3s Cluster
- **VM Size**: Standard_B2as_v2 (2 vCores, 4GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 30GB Premium SSD
- **IP**: Static private + public IP

</details>

## 📱 Applications

| Application | Purpose | URL Pattern |
|-------------|---------|-------------|
| **Strapi** | Headless CMS | `strapi.az.ameciclo.org` |
| **Atlas** | Traffic Data APIs | `atlas.az.ameciclo.org` |
| **Traefik** | Ingress Controller | Auto HTTPS |
| **ArgoCD** | GitOps Deployment | Internal |

### 🔄 GitOps Workflow
1. **Push** code changes to this repository
2. **ArgoCD** detects changes automatically
3. **Deploys** applications to Kubernetes cluster
4. **Notifies** via Telegram on success/failure

## 💰 Cost Breakdown

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| PostgreSQL | Standard_B2s | ~$25 |
| VM | Standard_B2as_v2 | ~$45 |
| Storage | Premium SSD | ~$2 |
| Networking | Standard | ~$8 |
| **Total** | | **~$80** |

## 🛠️ Management Commands

```bash
# Infrastructure
cd pulumi/infrastructure
pulumi stack output              # View outputs
pulumi up                       # Update infrastructure
pulumi destroy                  # ⚠️ Destroy everything

# Applications
ssh azureuser@$(pulumi stack output k3sPublicIp)  # Access cluster
kubectl get applications -n argocd                # View apps
kubectl get pods -A                              # Check status
```

## 🔒 Security Features

- ✅ **Private Database** - No public access
- ✅ **SSH Key Auth** - No password authentication
- ✅ **Network Security Groups** - Restricted port access
- ✅ **Secret Management** - Pulumi secrets + Infisical
- ✅ **Auto HTTPS** - Traefik + Let's Encrypt

## 📚 Documentation

- [📖 Detailed Docs](docs/) - Kubernetes guides and concepts
- [🏗️ Infrastructure Setup](pulumi/infrastructure/README.md) - Pulumi details
- [☸️ Application Configs](helm/) - Kubernetes manifests

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Test in a separate Pulumi stack
4. Submit a pull request

---

**Built with ❤️ by Ameciclo** | [Website](https://ameciclo.org) | [GitHub](https://github.com/Ameciclo)
