# Pulumi for Kubernetes and Configuration Management

## Can Pulumi Replace Ansible?

**Short answer:** Partially, but they serve different purposes.

### What Pulumi Does Well

✅ **Infrastructure Provisioning** (like Terraform)
- Cloud resources (VMs, networks, databases)
- Kubernetes clusters (AKS, EKS, GKE)
- DNS, storage, IAM, etc.

✅ **Kubernetes Resources** (like kubectl/Helm)
- Deployments, Services, Ingresses
- ConfigMaps, Secrets
- Custom Resources (CRDs)
- Helm charts

### What Ansible Does Well

✅ **Configuration Management**
- Installing packages on VMs
- Configuring services (nginx, k3s, etc.)
- File management and templating
- Running commands and scripts
- Idempotent system configuration

### The Overlap

Both can:
- Deploy Kubernetes resources
- Manage cloud infrastructure (with Ansible cloud modules)
- Template configurations

## Pulumi for Kubernetes

Yes! Pulumi has excellent Kubernetes support:

### 1. Native Kubernetes Resources

```typescript
import * as k8s from "@pulumi/kubernetes";

// Create a namespace
const ns = new k8s.core.v1.Namespace("app-namespace", {
    metadata: { name: "my-app" }
});

// Create a deployment
const deployment = new k8s.apps.v1.Deployment("app", {
    metadata: { namespace: ns.metadata.name },
    spec: {
        replicas: 3,
        selector: { matchLabels: { app: "my-app" } },
        template: {
            metadata: { labels: { app: "my-app" } },
            spec: {
                containers: [{
                    name: "app",
                    image: "nginx:latest",
                    ports: [{ containerPort: 80 }]
                }]
            }
        }
    }
});

// Create a service
const service = new k8s.core.v1.Service("app-service", {
    metadata: { namespace: ns.metadata.name },
    spec: {
        selector: { app: "my-app" },
        ports: [{ port: 80, targetPort: 80 }],
        type: "LoadBalancer"
    }
});
```

### 2. Helm Charts

```typescript
import * as k8s from "@pulumi/kubernetes";

// Deploy ArgoCD using Helm
const argocd = new k8s.helm.v3.Chart("argocd", {
    chart: "argo-cd",
    version: "7.3.3",
    namespace: "argocd",
    fetchOpts: {
        repo: "https://argoproj.github.io/argo-helm"
    },
    values: {
        server: {
            service: {
                type: "LoadBalancer"
            }
        }
    }
});
```

### 3. YAML Manifests

```typescript
import * as k8s from "@pulumi/kubernetes";

// Deploy from YAML files
const app = new k8s.yaml.ConfigFile("app", {
    file: "k8s-manifests/app.yaml"
});

// Deploy from directory
const charts = new k8s.yaml.ConfigGroup("charts", {
    files: "helm/charts/**/*.yaml"
});
```

## Recommended Architecture for Ameciclo

### Option 1: Pulumi + Ansible (Current Best Practice)

```
┌─────────────────────────────────────────────────┐
│ Pulumi (Infrastructure)                         │
│ - Azure Resource Group                          │
│ - Virtual Network                               │
│ - K3s VM (bare Ubuntu)                          │
│ - PostgreSQL                                    │
│ - DNS, Storage, etc.                            │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ Ansible (Configuration)                         │
│ - Install K3s on VM                             │
│ - Configure K3s settings                        │
│ - Install Helm                                  │
│ - Bootstrap ArgoCD                              │
│ - Install Tailscale                             │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ ArgoCD (Kubernetes Apps)                        │
│ - Strapi                                        │
│ - Atlas                                         │
│ - Kong                                          │
│ - Kestra                                        │
└─────────────────────────────────────────────────┘
```

**Why this works:**
- ✅ Pulumi manages cloud infrastructure (its strength)
- ✅ Ansible configures VMs (its strength)
- ✅ ArgoCD manages K8s apps (GitOps best practice)
- ✅ Clear separation of concerns

### Option 2: All Pulumi (Possible but Complex)

```typescript
// 1. Provision infrastructure
const vm = new azure.compute.VirtualMachine("k3s-vm", { ... });

// 2. Use Pulumi Command provider to run scripts
import * as command from "@pulumi/command";

const installK3s = new command.remote.Command("install-k3s", {
    connection: {
        host: vm.publicIpAddress,
        user: "azureuser",
        privateKey: fs.readFileSync("~/.ssh/id_rsa").toString()
    },
    create: "curl -sfL https://get.k3s.io | sh -"
});

// 3. Deploy Kubernetes resources
const provider = new k8s.Provider("k3s", {
    kubeconfig: installK3s.stdout
});

const argocd = new k8s.helm.v3.Chart("argocd", { ... }, { provider });
```

**Challenges:**
- ❌ More complex than Ansible for VM configuration
- ❌ Harder to debug SSH/remote execution issues
- ❌ Less idempotent for system configuration
- ⚠️ Mixing infrastructure and configuration concerns

### Option 3: Pulumi for Everything Except VM Config

```
Pulumi:
- ✅ Azure infrastructure
- ✅ Kubernetes resources (if you had managed K8s)
- ✅ Helm charts
- ❌ VM configuration (use Ansible)

Ansible:
- ✅ K3s installation
- ✅ System packages
- ✅ Service configuration
```

## For Your Specific Use Case

### Current Setup (Terraform + Ansible + ArgoCD)
```
Terraform → Azure + K3s VM
Ansible → Install K3s, ArgoCD, Tailscale
ArgoCD → Deploy apps (Strapi, Atlas, etc.)
```

### Recommended Migration (Pulumi + Ansible + ArgoCD)
```
Pulumi → Azure + K3s VM
Ansible → Install K3s, ArgoCD, Tailscale (keep as-is!)
ArgoCD → Deploy apps (keep as-is!)
```

**Why keep Ansible:**
1. Your `ansible/k3s-bootstrap-playbook.yml` is already working
2. Ansible is better for VM configuration
3. No need to rewrite working automation
4. Clear separation: Pulumi = infrastructure, Ansible = configuration

## If You Want to Use Pulumi for Kubernetes

You could replace your ArgoCD Applications with Pulumi:

### Current (ArgoCD)
```yaml
# helm/environments/prod/strapi-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: strapi
spec:
  source:
    repoURL: https://github.com/Ameciclo/groundwork.git
    path: helm/charts/strapi
```

### Alternative (Pulumi)
```typescript
// pulumi/k8s/index.ts
import * as k8s from "@pulumi/kubernetes";

const strapi = new k8s.yaml.ConfigGroup("strapi", {
    files: "../../helm/charts/strapi/*.yaml"
});
```

**But I don't recommend this because:**
- ❌ ArgoCD provides GitOps (automatic sync from Git)
- ❌ ArgoCD has better UI for app management
- ❌ ArgoCD is designed for continuous deployment
- ✅ Keep ArgoCD for application deployment

## Summary

### Use Pulumi For:
- ✅ Cloud infrastructure (Azure, AWS, GCP)
- ✅ Kubernetes clusters (AKS, EKS, GKE)
- ✅ Kubernetes resources (if not using ArgoCD)
- ✅ Helm charts (if not using ArgoCD)

### Keep Ansible For:
- ✅ VM configuration (installing K3s, packages)
- ✅ System setup (users, SSH, firewall)
- ✅ Service configuration (nginx, systemd)
- ✅ File management and templating

### Keep ArgoCD For:
- ✅ Kubernetes application deployment
- ✅ GitOps workflow
- ✅ Continuous deployment
- ✅ Application lifecycle management

## My Recommendation

**For Ameciclo, use this stack:**

1. **Pulumi** - Azure infrastructure (what we just created)
2. **Ansible** - K3s installation and VM setup (keep existing playbooks)
3. **ArgoCD** - Application deployment (keep existing setup)

This gives you:
- ✅ Type-safe infrastructure (Pulumi)
- ✅ Proven VM configuration (Ansible)
- ✅ GitOps for apps (ArgoCD)
- ✅ Best tool for each job

