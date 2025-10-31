# Azure VM Deployment Guide

This guide walks you through deploying the Azure infrastructure with a Standard_B2as_v2 VM for running Docker containers.

## Prerequisites

1. **Azure Account** with an active subscription
2. **Terraform** installed (v1.0+)
3. **Azure CLI** installed
4. **SSH Key Pair** for VM access

## Step 1: Generate SSH Key Pair (if you don't have one)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ameciclo_key -N ""
```

This creates:
- `~/.ssh/ameciclo_key` (private key - keep this safe!)
- `~/.ssh/ameciclo_key.pub` (public key - use this in Terraform)

## Step 2: Update terraform.tfvars

Edit `azure/terraform.tfvars` and replace the SSH public key:

```hcl
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

Get your public key:
```bash
cat ~/.ssh/ameciclo_key.pub
```

Copy the entire output and paste it into `terraform.tfvars`.

## Step 3: Initialize Terraform

```bash
cd azure
terraform init
```

## Step 4: Review the Plan

```bash
terraform plan -out=tfplan
```

This shows all resources that will be created:
- Virtual Network (VNet)
- VM Subnet
- Network Security Group (NSG) with SSH, HTTP, HTTPS rules
- Public IP Address
- Network Interface
- Linux Virtual Machine (Standard_B2as_v2)
- PostgreSQL Database (already created)
- Storage Account

## Step 5: Apply the Configuration

```bash
terraform apply tfplan
```

This will:
1. Create all networking resources
2. Create the VM
3. Install Docker and Docker Compose via custom script extension
4. Output the VM's public IP and SSH command

## Step 6: Connect to Your VM

After deployment completes, Terraform will output the SSH command:

```bash
ssh azureuser@<PUBLIC_IP>
```

Or use your private key:
```bash
ssh -i ~/.ssh/ameciclo_key azureuser@<PUBLIC_IP>
```

## Step 7: Verify Docker Installation

Once connected to the VM:

```bash
docker --version
docker-compose --version
docker ps
```

## Step 8: Configure PostgreSQL Connection

Update your connection string to point to Azure PostgreSQL:

```
postgresql://psqladmin:YourSecurePassword123!@ameciclo-postgres.postgres.database.azure.com:5432/atlas?sslmode=require
```

## Step 9: Deploy Your Services

You can now deploy Kong and your microservices using Docker Compose or Docker Swarm.

Example docker-compose.yml:
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

## Outputs

After deployment, Terraform outputs:

- `vm_id`: Virtual Machine ID
- `vm_name`: VM name
- `vm_public_ip`: Public IP address
- `vm_private_ip`: Private IP address
- `vm_ssh_command`: SSH command to connect
- `postgresql_server_fqdn`: PostgreSQL FQDN
- `postgresql_connection_string`: PostgreSQL connection string

## Cost Breakdown

Monthly costs:
- VM (Standard_B2as_v2): $19.27
- PostgreSQL (B2s): $28.35
- Storage & Networking: $11.45
- **Total: $59.07/month**

## Troubleshooting

### SSH Connection Refused
- Verify the public IP is correct: `terraform output vm_public_ip`
- Check NSG allows SSH (port 22): Should be in place
- Wait 2-3 minutes for VM to fully boot

### Docker Not Installed
- SSH into VM and check script logs:
  ```bash
  cat /var/log/waagent.log
  ```
- Manually install Docker:
  ```bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  ```

### PostgreSQL Connection Issues
- Verify firewall rules allow your VM's IP
- Check connection string format
- Test with psql:
  ```bash
  psql -h ameciclo-postgres.postgres.database.azure.com -U psqladmin -d atlas
  ```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

This will remove:
- VM and all associated resources
- Networking resources
- **Note**: PostgreSQL database will also be deleted!

## Next Steps

1. Deploy Kong API Gateway
2. Deploy Atlas microservices
3. Set up monitoring and logging
4. Configure backups for PostgreSQL
5. Set up CI/CD pipeline

