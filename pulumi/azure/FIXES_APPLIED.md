# Fixes Applied

## TypeScript Errors Fixed

### 1. Variable Redeclaration Error ✅

**Error:**
```
Cannot redeclare block-scoped variable 'resourceGroupName'. (ts 2451)
```

**Cause:**
- Line 22: `const resourceGroupName = config.get(...)`
- Line 427: `export const resourceGroupName = resourceGroup.name`

**Fix:**
Renamed the config variable to avoid conflict:
```typescript
// Before
const resourceGroupName = config.get("resource_group_name") || "ameciclo-rg";

// After
const resourceGroupNameConfig = config.get("resource_group_name") || "ameciclo-rg";
```

### 2. Module Not Found Error

**Error:**
```
Cannot find module '@pulumi/pulumi' or its corresponding type declarations. (ts 2307)
```

**Cause:**
TypeScript can't find the Pulumi packages because they haven't been installed yet.

**Fix:**
Run `npm install` in the `pulumi/azure` directory:
```bash
cd pulumi/azure
npm install
```

This will install:
- `@pulumi/pulumi` - Core Pulumi SDK
- `@pulumi/azure-native` - Azure Native provider
- TypeScript and type definitions

## Subnet Clarification

**Question:** "Why have you created so many subnets?"

**Answer:** Only **2 subnets** were created, exactly matching your Terraform configuration:

### Subnet 1: K3s Subnet
- **Name:** `k3s-subnet`
- **CIDR:** `10.10.1.0/24`
- **Purpose:** Hosts the K3s VM
- **Service Endpoints:** Microsoft.Storage
- **Resources:** K3s VM (10.10.1.4)

### Subnet 2: Database Subnet
- **Name:** `database-subnet`
- **CIDR:** `10.10.2.0/24`
- **Purpose:** Hosts PostgreSQL Flexible Server
- **Service Endpoints:** Microsoft.Storage
- **Delegation:** Microsoft.DBforPostgreSQL/flexibleServers (required for PostgreSQL)
- **Resources:** PostgreSQL server

### Network Architecture

```
Virtual Network: 10.10.0.0/16
├── K3s Subnet: 10.10.1.0/24
│   └── K3s VM: 10.10.1.4
└── Database Subnet: 10.10.2.0/24
    └── PostgreSQL: 10.10.2.4
```

This is **identical** to your Terraform configuration in `azure/network.tf`.

## Pulumi for Kubernetes and Ansible

**Question:** "Can you use Pulumi for Kubernetes stuff or Ansible too?"

**Answer:** Yes for Kubernetes, partially for Ansible-like tasks.

### What Pulumi Can Do

✅ **Kubernetes Resources**
- Native Kubernetes objects (Deployments, Services, etc.)
- Helm charts
- YAML manifests
- Custom Resource Definitions (CRDs)

✅ **Infrastructure**
- Cloud resources (VMs, networks, databases)
- Kubernetes clusters (AKS, EKS, GKE)
- DNS, storage, IAM

⚠️ **Configuration Management** (Limited)
- Can run remote commands via `@pulumi/command`
- Not as good as Ansible for VM configuration
- More complex for system setup tasks

### Recommended Stack for Ameciclo

```
┌─────────────────────────────────────┐
│ Pulumi                              │
│ - Azure infrastructure              │
│ - Resource groups, VNets, VMs       │
│ - PostgreSQL, DNS, Storage          │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Ansible (Keep existing!)            │
│ - Install K3s on VM                 │
│ - Configure system packages         │
│ - Bootstrap ArgoCD                  │
│ - Install Tailscale                 │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ ArgoCD (Keep existing!)             │
│ - Deploy Strapi                     │
│ - Deploy Atlas                      │
│ - Deploy Kong, Kestra, etc.         │
└─────────────────────────────────────┘
```

**Why this works best:**
- ✅ Pulumi manages cloud infrastructure (its strength)
- ✅ Ansible configures VMs (its strength)
- ✅ ArgoCD manages K8s apps (GitOps best practice)
- ✅ Clear separation of concerns
- ✅ Use the best tool for each job

See `../KUBERNETES_AND_ANSIBLE.md` for detailed comparison and examples.

## Next Steps

1. **Install dependencies:**
   ```bash
   cd pulumi/azure
   npm install
   ```

2. **Verify TypeScript compiles:**
   ```bash
   npm run build
   ```

3. **Test the setup:**
   ```bash
   pulumi login
   pulumi stack init test
   pulumi config set --secret groundwork-azure:postgresql_admin_password "test123"
   pulumi config set --secret groundwork-azure:admin_ssh_public_key "$(cat ~/.ssh/id_rsa.pub)"
   pulumi preview
   ```

All TypeScript errors should now be resolved! 🎉

