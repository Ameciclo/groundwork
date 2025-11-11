# Integration with Ansible

This document explains how Pulumi and Ansible work together in the Ameciclo infrastructure.

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Pulumi (Infrastructure + Kubernetes)            │
│ - Azure resources (VM, Network, Database)       │
│ - Kubernetes namespaces                         │
│ - ArgoCD and Tailscale Operator                 │
└─────────────────┬───────────────────────────────┘
                  │ Outputs: VM IP, kubeconfig
                  ▼
┌─────────────────────────────────────────────────┐
│ Ansible (VM Configuration)                      │
│ - Install K3s on VM                             │
│ - Configure K3s settings                        │
│ - Install Helm                                  │
│ - Bootstrap ArgoCD                              │
│ - Install Tailscale                             │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ K3s Cluster (Ready for Applications)            │
│ - ArgoCD (GitOps controller)                    │
│ - Tailscale Operator (networking)               │
│ - Application namespaces                        │
└─────────────────────────────────────────────────┘
```

## Workflow

### Step 1: Deploy Infrastructure with Pulumi

```bash
cd pulumi/azure
npm install
pulumi up
```

This creates:
- Azure VM with Ubuntu 22.04
- Virtual Network and subnets
- PostgreSQL database
- Public IP for VM access

**Outputs:**
- `k3sVmPublicIp` - Use this for Ansible
- `k3sVmSshCommand` - SSH command to connect

### Step 2: Run Ansible Playbook

```bash
# Get the VM IP from Pulumi
VM_IP=$(pulumi stack output k3sVmPublicIp)

# Run Ansible playbook
cd ../../ansible
ansible-playbook -i "$VM_IP," k3s-bootstrap-playbook.yml
```

The Ansible playbook:
- Installs K3s on the VM
- Configures K3s with proper TLS settings
- Installs Helm
- Bootstraps ArgoCD
- Installs Tailscale Operator
- Sets up monitoring

### Step 3: Verify Kubernetes Deployment

```bash
# Get kubeconfig from Pulumi
pulumi stack output kubeconfig > ~/.kube/config-ameciclo

# Verify cluster
export KUBECONFIG=~/.kube/config-ameciclo
kubectl get nodes
kubectl get pods -A
```

## Why This Approach?

### Pulumi Strengths
✅ Cloud infrastructure provisioning
✅ Type-safe infrastructure code
✅ Easy to manage cloud resources
✅ Kubernetes resource deployment

### Ansible Strengths
✅ VM configuration management
✅ Package installation
✅ Service configuration
✅ Idempotent system setup
✅ Proven for K3s installation

### Separation of Concerns
- **Pulumi**: "What cloud resources do we need?"
- **Ansible**: "How do we configure the VM?"
- **ArgoCD**: "What applications should run?"

## Comparison: Pulumi vs Ansible for K3s

| Task | Pulumi | Ansible | Recommended |
|------|--------|---------|-------------|
| Create VM | ✅ | ❌ | Pulumi |
| Install K3s | ⚠️ | ✅ | Ansible |
| Configure K3s | ⚠️ | ✅ | Ansible |
| Deploy Helm charts | ✅ | ⚠️ | Pulumi |
| Deploy K8s resources | ✅ | ⚠️ | Pulumi |
| System packages | ❌ | ✅ | Ansible |

## Troubleshooting

### Pulumi Deployment Fails

```bash
# Check Azure credentials
az login
az account show

# Check Pulumi state
pulumi stack
pulumi stack export > backup.json
```

### Ansible Playbook Fails

```bash
# Verify SSH access
ssh -i ~/.ssh/id_rsa azureuser@<VM_IP>

# Run with verbose output
ansible-playbook -i "$VM_IP," k3s-bootstrap-playbook.yml -vvv
```

### Kubernetes Not Ready

```bash
# Check K3s status on VM
ssh azureuser@<VM_IP> sudo systemctl status k3s

# Check kubeconfig
ssh azureuser@<VM_IP> sudo cat /etc/rancher/k3s/k3s.yaml
```

## Best Practices

1. **Always run Pulumi first**
   - Infrastructure must exist before configuration

2. **Use Pulumi outputs in Ansible**
   - Get VM IP from Pulumi
   - Use kubeconfig from Pulumi

3. **Keep Ansible playbooks idempotent**
   - Can be run multiple times safely
   - Useful for updates and fixes

4. **Version control everything**
   - Pulumi code in Git
   - Ansible playbooks in Git
   - Configuration in Pulumi.prod.yaml

5. **Document your setup**
   - Keep README files updated
   - Document any manual steps
   - Record environment variables

## Migration Path

If migrating from Terraform:

1. Deploy Pulumi infrastructure
2. Run Ansible playbook
3. Verify everything works
4. Destroy Terraform infrastructure
5. Keep Pulumi as source of truth

## Support

For issues:
- Pulumi: See `README.md` and `KUBERNETES_DEPLOYMENT.md`
- Ansible: See `../../ansible/k3s-bootstrap-playbook.yml`
- Kubernetes: See `KUBERNETES_DEPLOYMENT.md`

