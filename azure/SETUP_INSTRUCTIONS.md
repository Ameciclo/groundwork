# Azure VM Setup Instructions

## Overview

Your Terraform configuration is ready to deploy a complete Azure infrastructure with:
- **Standard_B2as_v2 VM** (2 vCPU, 8 GB RAM) - $19.27/month
- **PostgreSQL B2s Database** (already deployed) - $28.35/month
- **Networking & Storage** - $11.45/month
- **Total: $59.07/month** ✅

## Prerequisites

Before you start, ensure you have:

1. **Terraform** installed (v1.0+)
   ```bash
   terraform --version
   ```

2. **Azure CLI** installed
   ```bash
   az --version
   ```

3. **SSH Key Pair** (or generate one)
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/ameciclo_key -N ""
   ```

## Step-by-Step Setup

### Step 1: Get Your SSH Public Key

```bash
cat ~/.ssh/ameciclo_key.pub
```

Copy the entire output. It should look like:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7vbsGtkXYo... user@hostname
```

### Step 2: Update terraform.tfvars

Edit `azure/terraform.tfvars` and find this line:
```hcl
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

Replace it with your actual SSH public key from Step 1.

### Step 3: Initialize Terraform

```bash
cd azure
terraform init
```

This downloads the Azure provider and initializes the working directory.

### Step 4: Review the Plan

```bash
terraform plan -out=tfplan
```

This shows all resources that will be created. Review the output to ensure everything looks correct.

Expected resources:
- 1 Virtual Network
- 2 Subnets (VM and Database)
- 1 Network Security Group (VM)
- 1 Public IP Address
- 1 Network Interface
- 1 Linux Virtual Machine
- 1 VM Extension (Docker installation)

### Step 5: Apply the Configuration

```bash
terraform apply tfplan
```

This creates all the resources. Wait for completion (usually 5-10 minutes).

### Step 6: Get Your VM Details

```bash
terraform output
```

Key outputs:
- `vm_public_ip`: Your VM's public IP address
- `vm_ssh_command`: Ready-to-use SSH command
- `postgresql_server_fqdn`: Database hostname

### Step 7: Connect to Your VM

Option A - Using the SSH command from Terraform:
```bash
terraform output vm_ssh_command
# Copy and paste the output
```

Option B - Manual SSH:
```bash
ssh -i ~/.ssh/ameciclo_key azureuser@<PUBLIC_IP>
```

Replace `<PUBLIC_IP>` with the value from `terraform output vm_public_ip`.

### Step 8: Verify Docker Installation

Once connected to the VM:

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

All commands should work without errors.

## Configuration Files

### terraform.tfvars
Contains all configuration values:
- VM name, size, image
- Admin username
- SSH public key
- PostgreSQL settings
- Storage account settings

### vm.tf
Defines VM resources:
- Public IP
- Network Interface
- Linux Virtual Machine
- Docker installation script

### network.tf
Defines networking:
- VM Subnet
- Network Security Group
- Security rules (SSH, HTTP, HTTPS)

### variables.tf
Defines all variables with defaults and descriptions.

### outputs.tf
Defines outputs that are displayed after deployment.

## Deploying Your Services

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

## Troubleshooting

### SSH Connection Refused
- Verify the public IP: `terraform output vm_public_ip`
- Wait 2-3 minutes for VM to fully boot
- Check NSG allows SSH (port 22)

### Docker Not Installed
SSH into VM and check logs:
```bash
cat /var/log/waagent.log
```

Manually install Docker:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### PostgreSQL Connection Issues
Test connection from VM:
```bash
psql -h ameciclo-postgres.postgres.database.azure.com \
     -U psqladmin \
     -d atlas
```

### Terraform Errors
Reinitialize Terraform:
```bash
rm -rf .terraform
terraform init
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete the VM, networking, and PostgreSQL database!

## Cost Monitoring

Monitor your costs in Azure Portal:
1. Go to Cost Management + Billing
2. Select your subscription
3. View costs by resource

Expected monthly cost: **$59.07**

## Next Steps

1. ✅ Deploy VM (you are here)
2. Deploy Kong API Gateway
3. Deploy Atlas microservices
4. Set up monitoring and logging
5. Configure backups for PostgreSQL
6. Set up CI/CD pipeline

## Support

For more information, see:
- `VM_QUICK_START.md` - 5-minute quick start
- `VM_DEPLOYMENT.md` - Detailed deployment guide
- `TROUBLESHOOTING.md` - Common issues and solutions

