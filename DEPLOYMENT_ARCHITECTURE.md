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
- [x] **ArgoCD:** Deploy applications from Git
  - [x] Create Git repository with application manifests
  - [x] Create ArgoCD Application resources pointing to Git repo
  - [x] Verify applications are deployed automatically
  - [x] Test GitOps workflow: commit → ArgoCD → deployed

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

## Phase 6: Production Hardening - Implementation Guide

### 1. Configure RBAC Policies 🔐

**What it is:** Role-Based Access Control - restricts who can do what in your cluster.

**Implementation steps:**

1. **Create ServiceAccounts** for different applications/teams
2. **Define Roles** with specific permissions (get, list, create, update, delete)
3. **Bind Roles to ServiceAccounts** using RoleBindings
4. **Apply least privilege principle** - give only minimum permissions needed

**Example RBAC setup:**
```yaml
# ServiceAccount for application
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-deployer
  namespace: default

---
# Role with limited permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer-role
  namespace: default
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]

---
# Bind role to service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer-role
subjects:
- kind: ServiceAccount
  name: app-deployer
  namespace: default
```

**Tools:** Kubernetes native RBAC (no additional tools needed)

---

### 2. Set up Monitoring and Logging 📊

**What it is:** Observability - see what's happening in your cluster and applications.

**Monitoring (Metrics):**
- Deploy **Prometheus** - collects metrics from cluster and applications
- Deploy **Grafana** - visualizes metrics in dashboards
- Set up **AlertManager** - sends alerts when things go wrong

**Logging (Logs):**
- Deploy **Loki** - lightweight log aggregation
- Deploy **Promtail** - ships logs to Loki
- Alternative: **ELK Stack** (Elasticsearch, Logstash, Kibana) for larger deployments

**Installation via Helm:**
```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus + Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Install Loki + Promtail
helm install loki grafana/loki-stack \
  --namespace monitoring
```

**What to monitor:**
- CPU, memory, disk usage
- Pod restarts and failures
- API response times
- Error rates
- Custom application metrics

---

### 3. Configure Backup Strategy 💾

**What it is:** Ensure you can recover from disasters.

**Backup components:**
- **Kubernetes cluster state** - via Velero
- **Persistent data** - PostgreSQL backups
- **Manifests** - already in Git ✅
- **Secrets and ConfigMaps** - included in Velero backups

**Installation via Helm:**
```bash
# Add Velero Helm repository
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# Install Velero with Azure backend
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation.bucket=ameciclo-backups \
  --set configuration.backupStorageLocation.provider=azure \
  --set configuration.schedules.daily.schedule="0 2 * * *" \
  --set configuration.schedules.daily.template.ttl="720h"
```

**PostgreSQL backup strategy:**
- Enable automated backups in Azure PostgreSQL (7-35 days retention)
- Export backups to Azure Blob Storage
- Test restore procedures monthly

**Backup checklist:**
- [ ] Daily automated backups enabled
- [ ] Backups stored in separate location (Azure Blob Storage)
- [ ] Multiple backup versions retained (daily, weekly, monthly)
- [ ] Restore procedures tested and documented
- [ ] Recovery Time Objective (RTO) defined (e.g., 1 hour)
- [ ] Recovery Point Objective (RPO) defined (e.g., 1 day)

---

### 4. Set up Disaster Recovery Procedures 🚨

**What it is:** Step-by-step procedures to recover from failures.

**Create runbooks for:**

**Scenario 1: Cluster completely down**
```markdown
1. Verify cluster is down: kubectl cluster-info
2. Check Azure VM status in Azure Portal
3. If VM is down, restart it
4. If cluster is corrupted, restore from Velero:
   - velero restore create --from-backup <backup-name>
5. Verify all pods are running: kubectl get pods --all-namespaces
6. Check ArgoCD is synced: kubectl get applications -n argocd
7. Verify applications are healthy
```

**Scenario 2: Database corrupted**
```markdown
1. Stop all applications accessing database
2. Restore PostgreSQL from backup in Azure Portal
3. Verify data integrity
4. Restart applications
5. Monitor for errors
```

**Scenario 3: Accidental deletion of resources**
```markdown
1. Check if resource is in Git (should be)
2. If yes, ArgoCD will auto-recreate it (self-healing)
3. If no, restore from Velero backup
4. Verify resource is restored
```

**Scenario 4: Security breach / compromised secrets**
```markdown
1. Rotate all secrets: kubectl delete secret <secret-name> -n <namespace>
2. Update secret values in secure location
3. Recreate secrets: kubectl create secret generic <secret-name> ...
4. Restart affected pods to pick up new secrets
5. Review audit logs: kubectl logs -n kube-system
6. Update RBAC policies if needed
```

**Testing procedures:**
- [ ] Run disaster recovery drills monthly
- [ ] Simulate failures and practice recovery
- [ ] Time how long recovery takes (RTO)
- [ ] Measure data loss (RPO)
- [ ] Document lessons learned
- [ ] Update runbooks based on findings

---

### Implementation Order (Recommended)

1. **Start with Monitoring** (easiest, most valuable)
   - Deploy Prometheus + Grafana
   - Get visibility into your cluster
   - Set up basic alerts

2. **Add Logging** (complements monitoring)
   - Deploy Loki + Promtail
   - Centralize all logs
   - Create log dashboards

3. **Configure RBAC** (security)
   - Start with basic roles for applications
   - Gradually refine permissions
   - Document access policies

4. **Set up Backups** (critical)
   - Deploy Velero
   - Configure PostgreSQL backups
   - Test restore procedures

5. **Document Runbooks** (ongoing)
   - Create disaster recovery procedures
   - Test them regularly
   - Keep them updated

---

### Tools Summary

| Component | Tool | Purpose | Helm Chart |
|-----------|------|---------|-----------|
| Monitoring | Prometheus | Metrics collection | `prometheus-community/kube-prometheus-stack` |
| Monitoring | Grafana | Visualization | Included in kube-prometheus-stack |
| Logging | Loki | Log aggregation | `grafana/loki-stack` |
| Logging | Promtail | Log shipper | Included in loki-stack |
| Backup | Velero | Cluster backup/restore | `vmware-tanzu/velero` |
| RBAC | Kubernetes native | Access control | Built-in (no Helm needed) |

---

### Estimated Effort

- **RBAC:** 2-4 hours (create roles for your applications)
- **Monitoring:** 4-6 hours (deploy, configure dashboards, alerts)
- **Logging:** 2-3 hours (deploy, configure log retention)
- **Backups:** 3-4 hours (deploy Velero, test restores)
- **Runbooks:** 4-6 hours (document procedures, test them)

**Total:** ~15-25 hours for complete production hardening

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
- ✅ Created nginx-demo Helm chart for GitOps testing
- ✅ Deployed nginx-demo via ArgoCD Application
- ✅ Tested GitOps workflow: commit → ArgoCD → deployed
- ✅ Verified self-healing: deleted pods automatically recreated
- ✅ Verified application accessibility via Tailscale Ingress

**In Progress:**
- 🔄 None

**Pending:**
- ⏳ Set up production hardening (RBAC, monitoring, logging, backups)
- ⏳ Deploy additional applications via GitOps

## Kubeconfig Update

Your kubeconfig has been updated to use the Tailscale-accessible IP:
```
Server: https://10.10.1.4:6443
```

This allows you to access the K3s cluster via Tailscale VPN without needing to SSH to the VM.


