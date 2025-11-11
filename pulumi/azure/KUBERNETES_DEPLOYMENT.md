# Kubernetes Deployment with Pulumi

This guide explains how to deploy Kubernetes resources to your K3s cluster using Pulumi.

## Overview

The Pulumi configuration now includes:

1. **Kubernetes Provider** - Connects to the K3s cluster on the Azure VM
2. **Namespaces** - Creates isolated namespaces for applications
3. **ArgoCD** - GitOps continuous deployment platform
4. **Tailscale Operator** - Secure networking for the cluster
5. **ArgoCD Applications** - Deploys Strapi, Atlas, Kong, and Kestra

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Pulumi (Infrastructure + Kubernetes)            │
│ - Azure resources (VM, Network, Database)       │
│ - Kubernetes namespaces                         │
│ - ArgoCD and Tailscale Operator                 │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ K3s Cluster (on Azure VM)                       │
│ - ArgoCD (GitOps controller)                    │
│ - Tailscale Operator (networking)               │
│ - Application namespaces                        │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ ArgoCD Applications (GitOps)                    │
│ - Strapi (CMS)                                  │
│ - Atlas (API)                                   │
│ - Kong (API Gateway)                            │
│ - Kestra (Workflow Orchestration)               │
└─────────────────────────────────────────────────┘
```

## Prerequisites

Before deploying Kubernetes resources, ensure:

1. **Infrastructure is deployed**: Run `pulumi up` to create Azure resources
2. **K3s is installed**: The Ansible playbook must have been run
3. **SSH access**: You can SSH into the K3s VM
4. **Secrets configured**: All required secrets are set

## Configuration

### Required Secrets

Set these secrets before deploying:

```bash
# SSH private key (for accessing K3s VM)
pulumi config set --secret groundwork-azure:admin_ssh_private_key "$(cat ~/.ssh/id_rsa)"

# ArgoCD admin password
pulumi config set --secret groundwork-azure:argocd_admin_password <your-secure-password>

# Tailscale OAuth credentials
pulumi config set --secret groundwork-azure:tailscale_oauth_client_id <your-client-id>
pulumi config set --secret groundwork-azure:tailscale_oauth_client_secret <your-client-secret>
```

### Optional Configuration

Edit `Pulumi.prod.yaml` to customize:

```yaml
groundwork-azure:argocd_version: "7.3.3"
groundwork-azure:tailscale_operator_version: "1.90.6"
groundwork-azure:git_repo_url: https://github.com/Ameciclo/groundwork.git
```

## Deployment

### 1. Install Dependencies

```bash
cd pulumi/azure
npm install
```

### 2. Preview Changes

```bash
pulumi preview
```

### 3. Deploy

```bash
pulumi up
```

This will:
- Retrieve kubeconfig from K3s VM
- Create Kubernetes namespaces
- Deploy ArgoCD via Helm
- Deploy Tailscale Operator via Helm
- Create ArgoCD Applications for your apps

## Accessing Applications

### ArgoCD UI

```bash
# Get ArgoCD service info
kubectl get svc -n argocd

# Port forward to access UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Access at https://localhost:8080
# Username: admin
# Password: (from argocd_admin_password config)
```

### Application Namespaces

```bash
# List all namespaces
kubectl get namespaces

# Check application status
kubectl get pods -n strapi
kubectl get pods -n atlas
kubectl get pods -n kong
kubectl get pods -n kestra
```

## Troubleshooting

### SSH Connection Issues

If Pulumi can't connect to the K3s VM:

```bash
# Verify SSH access
ssh -i ~/.ssh/id_rsa azureuser@<k3s-vm-public-ip>

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Kubeconfig Retrieval

If kubeconfig retrieval fails:

```bash
# Manually get kubeconfig
ssh azureuser@<k3s-vm-public-ip> sudo cat /etc/rancher/k3s/k3s.yaml

# Update the server address to use the public IP
```

### ArgoCD Deployment Issues

```bash
# Check ArgoCD pod status
kubectl get pods -n argocd

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

## File Structure

```
pulumi/azure/
├── index.ts              # Main infrastructure + K8s orchestration
├── k8s.ts               # Kubernetes resources (namespaces, Helm charts)
├── argocd-apps.ts       # ArgoCD Application definitions
├── package.json         # Dependencies
└── KUBERNETES_DEPLOYMENT.md  # This file
```

## Next Steps

1. Verify all resources are deployed: `pulumi stack output`
2. Access ArgoCD UI and monitor application deployments
3. Check application status in their respective namespaces
4. Configure Tailscale for secure access to the cluster

