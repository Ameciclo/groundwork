# Deployment Architecture

## Overview

This repository follows a **Bootstrap → GitOps** pattern for deploying infrastructure across any cloud provider.

## Architecture Pattern

### Phase 1: Bootstrap (Manual - One Time)

```
Terraform (any cloud)
    ↓
Ansible (K3s + Tailscale Operator)
    ↓
Tailscale Connector (auto-created)
    ↓
VPN Access to K3s cluster
```

**Why Tailscale first?**
- You need VPN access to reach ArgoCD
- Tailscale Operator automatically creates the Connector resource
- No manual CRD management needed

### Phase 2: GitOps (Automated - Continuous)

```
Git Repository
    ↓
ArgoCD (deployed via Helm in bootstrap)
    ↓
Watches Git for changes
    ↓
Deploys applications automatically
```

**Result:**
- All infrastructure defined in Git
- Changes automatically deployed
- Reproducible across any cloud provider

## Directory Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── *.tf               # Root-level (DigitalOcean, etc.)
│   └── azure/             # Azure-specific
├── ansible/               # Configuration Management
│   ├── playbook.yml       # Docker Swarm + Portainer
│   └── k3s-bootstrap-playbook.yml  # K3s + Tailscale + ArgoCD
├── helm/                  # Kubernetes Applications
│   ├── charts/
│   │   └── tailscale/     # Tailscale Operator (cloud-agnostic)
│   └── values/
│       └── prod.yaml      # Production overrides
└── stacks/                # Docker Compose Stacks
    ├── atlas/             # Atlas service
    └── kestra/            # Kestra workflow engine
```

## Deployment Flow

### For Azure (or any cloud)

1. **Provision Infrastructure**
   ```bash
   cd azure
   terraform apply
   ```

2. **Bootstrap K3s + Tailscale**
   ```bash
   ansible-playbook -i ansible/k3s-azure-inventory.yml \
     ansible/k3s-bootstrap-playbook.yml
   ```

3. **Access ArgoCD via Tailscale**
   - Connect to Tailscale VPN
   - Access ArgoCD at `http://argocd.armadillo-hamal.ts.net`

4. **Deploy Applications via ArgoCD**
   - All subsequent deployments are GitOps-managed
   - Changes in Git → ArgoCD → Deployed automatically

## Key Components

### Terraform
- **Purpose:** Provision cloud infrastructure (VMs, networks, databases)
- **Cloud-agnostic:** Works with AWS, GCP, Azure, DigitalOcean, etc.
- **Location:** `terraform/` (root) and `azure/` (Azure-specific)

### Ansible
- **Purpose:** Configure VMs and install K3s
- **Playbooks:**
  - `playbook.yml` - Docker Swarm + Portainer (for Docker-based deployments)
  - `k3s-bootstrap-playbook.yml` - K3s + Tailscale + ArgoCD (for Kubernetes)

### Helm
- **Purpose:** Deploy Kubernetes applications
- **Tailscale Chart:** Cloud-agnostic, reusable across all providers
- **Values:** Production configuration overrides

### Docker Stacks
- **Purpose:** Docker Compose-based services
- **Services:** Atlas, Kestra
- **Deployment:** Via Portainer or direct `docker stack deploy`

## Tailscale Integration

### Why Tailscale?
- Secure VPN access to K3s cluster
- No public IP exposure needed
- Works across all cloud providers
- Automatic Connector creation via Operator

### How It Works
1. Tailscale Operator is installed during bootstrap
2. Operator automatically creates a Connector resource
3. Connector advertises K3s networks to Tailscale
4. You connect to Tailscale VPN to access cluster services

### Accessing Services
- **ArgoCD:** `http://argocd.armadillo-hamal.ts.net` (via Tailscale)
- **K3s API:** `https://10.20.1.4:6443` (via Tailscale VPN)
- **Other services:** Configured via Tailscale Ingress

## Multi-Cloud Deployment

This architecture is designed for multi-cloud portability:

1. **Terraform** handles cloud-specific infrastructure
2. **Ansible** handles K3s installation (cloud-agnostic)
3. **Helm** handles Kubernetes applications (cloud-agnostic)
4. **Tailscale** provides VPN access (cloud-agnostic)

To deploy to a new cloud provider:
1. Create new Terraform configuration for that cloud
2. Run the same Ansible playbook
3. Same Helm charts work everywhere
4. Same GitOps workflow applies

## Security

- **VPN-only access:** All cluster access via Tailscale VPN
- **No public IPs:** Services not exposed to the internet
- **GitOps audit trail:** All changes tracked in Git
- **Declarative configuration:** Infrastructure as Code

## Implementation Checklist

### Phase 1: Infrastructure Setup
- [x] **Terraform:** Provision K3s cluster on target cloud provider
  - [x] Configure cloud provider credentials
  - [x] Run `terraform apply` to create infrastructure
  - [x] Verify VM is running and accessible via SSH

### Phase 2: Bootstrap K3s + Tailscale
- [x] **Ansible:** Install K3s and Tailscale Operator
  - [x] Set Tailscale OAuth credentials as environment variables
  - [x] Run `k3s-bootstrap-playbook.yml`
  - [x] Verify K3s cluster is running: `kubectl get nodes`
  - [x] Verify Tailscale Operator is deployed: `kubectl get pods -n tailscale`
  - [x] Verify Tailscale Connector is created: `kubectl get connector -n tailscale`

### Phase 3: Access via Tailscale VPN
- [x] **Tailscale:** Connect to VPN and access cluster
  - [x] Connect to Tailscale VPN on your machine
  - [x] Verify connectivity to cluster network
  - [x] Access ArgoCD: `http://argocd.armadillo-hamal.ts.net`
  - [x] Login to ArgoCD with default credentials

### Phase 4: GitOps Management
- [ ] **ArgoCD:** Deploy applications from Git
  - [ ] Create Git repository with application manifests
  - [ ] Create ArgoCD Application resources pointing to Git repo
  - [ ] Verify applications are deployed automatically
  - [ ] Test GitOps workflow: commit → ArgoCD → deployed

### Phase 5: Cleanup
- [x] **Remove Kong from K3s cluster**
  - [x] Uninstall Kong Helm release: `helm uninstall kong -n kong`
  - [x] Delete Kong namespace: `kubectl delete namespace kong`
  - [x] Verify Kong is removed: `kubectl get all -n kong`

### Phase 6: Production Hardening (Optional)
- [ ] Configure RBAC policies
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Set up disaster recovery procedures

## Current Status

**Completed:**
- ✅ Repository cleanup and restructuring
- ✅ Removed Kong from Docker Swarm (stacks/kong/)
- ✅ Removed Azure-specific Kubernetes configs
- ✅ Defined Bootstrap → GitOps architecture
- ✅ Updated kubeconfig to use Tailscale-accessible IP (10.10.1.4:6443)
- ✅ Deployed Tailscale Operator and Connector CRD
- ✅ Enabled route acceptance on local machine (`--accept-routes`)
- ✅ Verified K3s cluster connectivity via Tailscale VPN
- ✅ Removed Kong from K3s cluster (deleted ArgoCD Application and namespace)
- ✅ Verified all Kong resources are removed
- ✅ Removed TAILSCALE_K3S_ACCESS.md and K3S_QUICK_ACCESS.md documentation

**In Progress:**
- 🔄 None

**Pending:**
- ⏳ Deploy applications via ArgoCD (GitOps workflow)
- ⏳ Set up production hardening (RBAC, monitoring, logging, backups)

## Kubeconfig Update

Your kubeconfig has been updated to use the Tailscale-accessible IP:
```
Server: https://10.10.1.4:6443
```

This allows you to access the K3s cluster via Tailscale VPN without needing to SSH to the VM.


