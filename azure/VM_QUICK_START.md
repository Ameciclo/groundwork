# VM Quick Start - 5 Minutes to Deployment

## TL;DR

```bash
# 1. Generate SSH key (if needed)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ameciclo_key -N ""

# 2. Get your public key
cat ~/.ssh/ameciclo_key.pub

# 3. Update terraform.tfvars with your SSH public key
# Edit: azure/terraform.tfvars
# Replace: admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."

# 4. Deploy
cd azure
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 5. Connect
ssh azureuser@<PUBLIC_IP>

# 6. Verify Docker
docker --version
```

## What Gets Deployed

✅ **Compute**
- Standard_B2as_v2 VM (2 vCPU, 8 GB RAM)
- Ubuntu 22.04 LTS
- Docker & Docker Compose pre-installed

✅ **Networking**
- Virtual Network (10.10.0.0/16)
- VM Subnet (10.10.3.0/24)
- Network Security Group with SSH, HTTP, HTTPS
- Public IP Address
- Network Interface

✅ **Database** (Already deployed)
- PostgreSQL B2s (2 vCPU, 4 GB RAM)
- 32 GB Storage
- Automatic backups

## Configuration

### SSH Public Key

Get your public key:
```bash
cat ~/.ssh/ameciclo_key.pub
```

Output looks like:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7vbsGtkXYo... user@hostname
```

Update `terraform.tfvars`:
```hcl
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7vbsGtkXYo... user@hostname"
```

### VM Configuration

Current settings in `terraform.tfvars`:
```hcl
vm_name              = "ameciclo-vm"
vm_size              = "Standard_B2as_v2"
vm_os_disk_size_gb   = 30
vm_image_publisher   = "Canonical"
vm_image_offer       = "0001-com-ubuntu-server-jammy"
vm_image_sku         = "22_04-lts-gen2"
vm_image_version     = "latest"
admin_username       = "azureuser"
```

## Deployment Steps

### Step 1: Initialize
```bash
cd azure
terraform init
```

### Step 2: Plan
```bash
terraform plan -out=tfplan
```

Review the output to see what will be created.

### Step 3: Apply
```bash
terraform apply tfplan
```

Wait for completion (usually 5-10 minutes).

### Step 4: Get Outputs
```bash
terraform output
```

Key outputs:
- `vm_public_ip`: Your VM's public IP
- `vm_ssh_command`: Ready-to-use SSH command
- `postgresql_server_fqdn`: Database hostname

## Connect to VM

### Option 1: Using SSH command from Terraform
```bash
terraform output vm_ssh_command
# Output: ssh azureuser@<PUBLIC_IP>
```

### Option 2: Manual SSH
```bash
ssh -i ~/.ssh/ameciclo_key azureuser@<PUBLIC_IP>
```

### Option 3: Using Azure CLI
```bash
az vm open-port --resource-group ameciclo-rg-prod --name ameciclo-vm --port 22
```

## Verify Installation

Once connected to VM:

```bash
# Check Docker
docker --version
docker ps

# Check Docker Compose
docker-compose --version

# Check system resources
free -h
df -h
```

## Deploy Your Services

### Example: Deploy Kong

```bash
docker run -d \
  --name kong \
  -p 80:8000 \
  -p 443:8443 \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=ameciclo-postgres.postgres.database.azure.com \
  -e KONG_PG_USER=psqladmin \
  -e KONG_PG_PASSWORD=YourSecurePassword123! \
  kong:latest
```

### Example: Deploy with Docker Compose

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  kong:
    image: kong:latest
    ports:
      - "80:8000"
      - "443:8443"
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: ameciclo-postgres.postgres.database.azure.com
      KONG_PG_USER: psqladmin
      KONG_PG_PASSWORD: YourSecurePassword123!
```

Deploy:
```bash
docker-compose up -d
```

## Costs

| Component | Cost/Month |
|-----------|-----------|
| VM (B2as_v2) | $19.27 |
| PostgreSQL (B2s) | $28.35 |
| Storage & Networking | $11.45 |
| **Total** | **$59.07** |

Budget remaining: **$70.93/month** ✅

## Troubleshooting

### Can't SSH?
```bash
# Check if VM is running
terraform output vm_public_ip

# Wait 2-3 minutes for VM to boot
# Check NSG allows SSH (port 22)
```

### Docker not working?
```bash
# Check installation logs
cat /var/log/waagent.log

# Manually install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### PostgreSQL connection issues?
```bash
# Test connection from VM
psql -h ameciclo-postgres.postgres.database.azure.com \
     -U psqladmin \
     -d atlas
```

## Cleanup

Destroy all resources:
```bash
terraform destroy
```

⚠️ **Warning**: This will delete the VM, networking, and PostgreSQL database!

## Next Steps

1. ✅ Deploy VM (you are here)
2. Deploy Kong API Gateway
3. Deploy Atlas microservices
4. Set up monitoring
5. Configure backups
6. Set up CI/CD

## Support

For issues, check:
- `azure/VM_DEPLOYMENT.md` - Detailed guide
- `azure/TROUBLESHOOTING.md` - Common issues
- Azure Portal - Resource status

