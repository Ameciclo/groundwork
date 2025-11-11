# Kubernetes Setup with Pulumi - Summary

## What Was Added

This update adds complete Kubernetes deployment capabilities to the Pulumi infrastructure setup. The system now automatically deploys and configures Kubernetes resources on the K3s cluster.

## New Files Created

1. **k8s.ts** - Kubernetes resource definitions
   - Kubernetes provider configuration
   - Namespace creation
   - ArgoCD Helm deployment
   - Tailscale Operator Helm deployment

2. **argocd-apps.ts** - ArgoCD application definitions
   - ArgoCD Application CRD creation
   - Application deployment for Strapi, Atlas, Kong, Kestra

3. **KUBERNETES_DEPLOYMENT.md** - Detailed deployment guide

## Modified Files

1. **index.ts** - Main infrastructure file
   - Added Kubernetes imports
   - Added kubeconfig retrieval from K3s VM
   - Added Kubernetes provider initialization
   - Added namespace creation
   - Added ArgoCD and Tailscale deployment
   - Added ArgoCD applications deployment
   - Added Kubernetes outputs

2. **package.json** - Dependencies
   - Added `@pulumi/kubernetes` (^4.0.0)
   - Added `@pulumi/command` (^0.9.0)

3. **Pulumi.prod.yaml.example** - Configuration template
   - Added Kubernetes configuration options
   - Added required secrets documentation

## Architecture

```
Pulumi (Infrastructure + Kubernetes)
    ↓
Azure Resources (VM, Network, Database)
    ↓
K3s Cluster (on Azure VM)
    ├── ArgoCD (GitOps controller)
    ├── Tailscale Operator (networking)
    └── Application Namespaces
        ├── strapi
        ├── atlas
        ├── kong
        └── kestra
```

## Deployment Flow

1. **Infrastructure Phase** (existing)
   - Azure Resource Group
   - Virtual Network & Subnets
   - Network Security Groups
   - K3s VM (Ubuntu 22.04)
   - PostgreSQL Database

2. **Kubernetes Phase** (new)
   - Retrieve kubeconfig from K3s VM
   - Create Kubernetes namespaces
   - Deploy ArgoCD via Helm
   - Deploy Tailscale Operator via Helm
   - Create ArgoCD Applications for apps

## Required Configuration

### New Secrets to Set

```bash
# SSH private key for K3s VM access
pulumi config set --secret groundwork-azure:admin_ssh_private_key "$(cat ~/.ssh/id_rsa)"

# ArgoCD admin password
pulumi config set --secret groundwork-azure:argocd_admin_password <password>

# Tailscale OAuth credentials
pulumi config set --secret groundwork-azure:tailscale_oauth_client_id <id>
pulumi config set --secret groundwork-azure:tailscale_oauth_client_secret <secret>
```

## Deployment Steps

```bash
# 1. Install dependencies
cd pulumi/azure
npm install

# 2. Preview changes
pulumi preview

# 3. Deploy
pulumi up
```

## Key Features

✅ **Automated Kubernetes Setup**
- No manual kubectl commands needed
- All resources created via Pulumi

✅ **GitOps Ready**
- ArgoCD automatically syncs from Git
- Applications defined in helm/charts/

✅ **Secure Networking**
- Tailscale Operator for private access
- Private DNS for PostgreSQL

✅ **Type-Safe**
- Full TypeScript support
- IDE autocomplete and type checking

## Outputs

After deployment, access outputs with:

```bash
pulumi stack output
```

Key outputs:
- `k3sVmPublicIp` - K3s VM public IP
- `kubeconfig` - Kubernetes configuration
- `argocdNamespace` - ArgoCD namespace
- `deployedApplications` - List of deployed apps

## Next Steps

1. Verify deployment: `pulumi stack output`
2. Access ArgoCD UI: `kubectl port-forward -n argocd svc/argocd-server 8080:443`
3. Monitor applications: `kubectl get pods -n <namespace>`
4. Configure Tailscale for secure cluster access

## Troubleshooting

See `KUBERNETES_DEPLOYMENT.md` for detailed troubleshooting guide.

## Files Structure

```
pulumi/azure/
├── index.ts                          # Main infrastructure + K8s
├── k8s.ts                           # Kubernetes resources
├── argocd-apps.ts                   # ArgoCD applications
├── package.json                     # Dependencies
├── KUBERNETES_DEPLOYMENT.md         # Detailed guide
├── KUBERNETES_SETUP_SUMMARY.md      # This file
└── Pulumi.prod.yaml.example         # Configuration template
```

