# K3s Setup on Azure VM - Ansible Guide

This guide walks you through setting up K3s and ArgoCD on your Azure VM using Ansible.

## Prerequisites

### 1. Azure VM Created
```bash
cd azure
terraform apply
```

Get the public IP:
```bash
terraform output vm_public_ip
```

### 2. SSH Key Setup
Ensure your SSH key is available:
```bash
# Check if key exists
ls ~/.ssh/id_rsa

# If not, create one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 3. Ansible Installed
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt-get install ansible

# Verify
ansible --version
```

## Setup Steps

### Step 1: Update Inventory

Edit `ansible/k3s-azure-inventory.yml` and replace `YOUR_VM_PUBLIC_IP`:

```bash
# Get the IP from Terraform
AZURE_IP=$(cd azure && terraform output -raw vm_public_ip)
echo "VM IP: $AZURE_IP"

# Update inventory
sed -i '' "s/YOUR_VM_PUBLIC_IP/$AZURE_IP/g" ansible/k3s-azure-inventory.yml
```

### Step 2: Test SSH Connection

```bash
# Test connectivity
ansible -i ansible/k3s-azure-inventory.yml k3s_azure -m ping

# Expected output:
# ameciclo-k3s-azure | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Step 3: Run K3s Installation Playbook

```bash
# Run the playbook
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml

# With verbose output (for debugging)
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml -v

# With extra verbose output
ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml -vv
```

The playbook will:
- Install K3s with containerd
- Install Helm
- Install ArgoCD
- Configure kubeconfig
- Display access credentials

### Step 4: Access ArgoCD

After the playbook completes, you'll see:

```
ArgoCD Access Information
========================================
URL: http://<YOUR_VM_IP>:80
Username: admin
Password: <GENERATED_PASSWORD>
```

Open the URL in your browser and log in.

### Step 5: Configure Git Repository

In ArgoCD:
1. Go to Settings → Repositories
2. Add your Git repository (e.g., Ameciclo/groundwork)
3. Configure the connection
4. Create applications pointing to your Kubernetes manifests

## Verify Installation

### SSH into VM and Check K3s

```bash
# SSH into VM
ssh -i ~/.ssh/id_rsa azureuser@<YOUR_VM_IP>

# Check K3s status
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A

# Check ArgoCD
sudo k3s kubectl get pods -n argocd
sudo k3s kubectl get svc -n argocd
```

### Check Kubeconfig

```bash
# On your local machine
cat ~/.kube/config

# Should show K3s cluster configuration
```

## Troubleshooting

### SSH Connection Refused
```bash
# Wait a few minutes for VM to boot
sleep 120

# Try again
ansible -i ansible/k3s-azure-inventory.yml k3s_azure -m ping
```

### K3s Installation Fails
```bash
# SSH into VM and check logs
ssh -i ~/.ssh/id_rsa azureuser@<YOUR_VM_IP>
sudo journalctl -u k3s -n 50

# Check disk space
df -h

# Check memory
free -h
```

### ArgoCD Not Accessible
```bash
# Check if service is running
sudo k3s kubectl get svc -n argocd

# Check pod status
sudo k3s kubectl get pods -n argocd

# Check logs
sudo k3s kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

## Next Steps

1. **Configure DNS**: Point your domain to the VM's public IP
2. **Setup Ingress**: Configure Kong or Nginx ingress controller
3. **Deploy Applications**: Use ArgoCD to deploy your services
4. **Setup Monitoring**: Install Prometheus and Grafana
5. **Configure Backups**: Setup automated backups for persistent data

## Files

- `ansible/k3s-azure-playbook.yml` - Main installation playbook
- `ansible/k3s-azure-inventory.yml` - Inventory configuration
- `azure/k3s.tf` - Terraform K3s VM configuration
- `azure/terraform.tfvars.example` - Terraform variables template

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Ansible logs: `ansible-playbook ... -vv`
3. Check K3s logs on the VM: `sudo journalctl -u k3s`
4. Check ArgoCD logs: `sudo k3s kubectl logs -n argocd ...`

