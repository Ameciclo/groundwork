# Azure VM Deployment Checklist

## Pre-Deployment Checklist

### Prerequisites
- [ ] Terraform installed (v1.0+)
- [ ] Azure CLI installed
- [ ] SSH key pair generated: `~/.ssh/ameciclo_key`
- [ ] SSH public key copied to clipboard

### Configuration
- [ ] SSH public key added to `azure/terraform.tfvars` (line 36)
- [ ] Verified `admin_ssh_public_key` is not the placeholder value
- [ ] Verified `vm_size` is set to `Standard_B2as_v2`
- [ ] Verified `region` is set to `westus3`
- [ ] Verified `admin_username` is set to `azureuser`

### Files Verified
- [ ] `azure/vm.tf` exists and contains VM resources
- [ ] `azure/scripts/install-docker.sh` exists and is executable
- [ ] `azure/variables.tf` contains VM variables
- [ ] `azure/network.tf` contains VM subnet and NSG
- [ ] `azure/outputs.tf` contains VM outputs
- [ ] `azure/terraform.tfvars` contains VM configuration

## Deployment Steps

### Step 1: Initialize Terraform
```bash
cd azure
terraform init
```
- [ ] Terraform initialized successfully
- [ ] `.terraform` directory created
- [ ] Provider plugins downloaded

### Step 2: Validate Configuration
```bash
terraform validate
```
- [ ] Configuration is valid
- [ ] No syntax errors

### Step 3: Review Plan
```bash
terraform plan -out=tfplan
```
- [ ] Plan shows expected resources:
  - [ ] 1 Public IP
  - [ ] 1 Network Interface
  - [ ] 1 Linux Virtual Machine
  - [ ] 1 VM Extension (Docker)
  - [ ] 1 VM Subnet
  - [ ] 1 Network Security Group
- [ ] No unexpected changes
- [ ] Plan saved to `tfplan`

### Step 4: Apply Configuration
```bash
terraform apply tfplan
```
- [ ] Deployment started
- [ ] Resources being created
- [ ] Wait for completion (5-10 minutes)
- [ ] All resources created successfully

### Step 5: Get Outputs
```bash
terraform output
```
- [ ] VM public IP displayed
- [ ] VM private IP displayed
- [ ] SSH command displayed
- [ ] PostgreSQL FQDN displayed

## Post-Deployment Verification

### SSH Connection
```bash
ssh azureuser@<PUBLIC_IP>
```
- [ ] SSH connection successful
- [ ] Logged in as `azureuser`
- [ ] No permission denied errors

### Docker Verification
```bash
docker --version
docker-compose --version
docker ps
```
- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] No containers running initially (expected)

### System Resources
```bash
free -h
df -h
uname -a
```
- [ ] 8 GB RAM available
- [ ] 30 GB disk available
- [ ] Ubuntu 22.04 LTS running
- [ ] 2 vCPU available

### Network Connectivity
```bash
curl -I https://www.google.com
```
- [ ] Internet connectivity working
- [ ] Can reach external services

### PostgreSQL Connectivity
```bash
psql -h ameciclo-postgres.postgres.database.azure.com \
     -U psqladmin \
     -d atlas \
     -c "SELECT version();"
```
- [ ] PostgreSQL connection successful
- [ ] Database version displayed
- [ ] Can query the database

## Service Deployment

### Kong API Gateway
- [ ] Kong container deployed
- [ ] Kong listening on port 80/443
- [ ] Kong connected to PostgreSQL
- [ ] Kong admin API accessible

### Atlas Microservices
- [ ] cyclist-profile service deployed
- [ ] cyclist-counts service deployed
- [ ] traffic-deaths service deployed
- [ ] All services connected to PostgreSQL
- [ ] All services behind Kong reverse proxy

### Monitoring
- [ ] Logs being collected
- [ ] Metrics being monitored
- [ ] Alerts configured

## Cost Verification

### Expected Monthly Costs
- [ ] VM (Standard_B2as_v2): $19.27
- [ ] PostgreSQL (B2s): $28.35
- [ ] Storage: $1.00
- [ ] Blob Storage: $1.80
- [ ] Data Transfer: $5.00
- [ ] Public IP: $2.50
- [ ] OS Disk: $1.15
- [ ] **Total: $59.07/month** ✅

### Budget Status
- [ ] Total cost within $130 budget
- [ ] $70.93/month remaining
- [ ] Cost monitoring enabled in Azure Portal

## Troubleshooting

### If SSH Connection Fails
- [ ] Verify public IP: `terraform output vm_public_ip`
- [ ] Wait 2-3 minutes for VM to boot
- [ ] Check NSG allows SSH (port 22)
- [ ] Verify SSH key permissions: `chmod 600 ~/.ssh/ameciclo_key`
- [ ] Check Azure Portal for VM status

### If Docker Not Installed
- [ ] SSH into VM
- [ ] Check logs: `cat /var/log/waagent.log`
- [ ] Manually install Docker if needed
- [ ] Verify extension status in Azure Portal

### If PostgreSQL Connection Fails
- [ ] Verify database is running in Azure Portal
- [ ] Check firewall rules allow VM subnet
- [ ] Verify credentials are correct
- [ ] Test from VM: `psql -h ameciclo-postgres.postgres.database.azure.com -U psqladmin`

## Cleanup (If Needed)

### Destroy All Resources
```bash
terraform destroy
```
- [ ] Confirmed destruction
- [ ] All resources deleted
- [ ] Terraform state cleaned up

⚠️ **Warning**: This will delete the VM, networking, and PostgreSQL database!

## Sign-Off

- [ ] All checks completed
- [ ] VM deployed successfully
- [ ] Docker verified working
- [ ] PostgreSQL connectivity confirmed
- [ ] Services ready to deploy
- [ ] Cost within budget

**Deployment Date**: _______________
**Deployed By**: _______________
**Notes**: _______________________________________________

---

## Next Steps

1. Deploy Kong API Gateway
2. Deploy Atlas microservices
3. Configure monitoring and logging
4. Set up automated backups
5. Configure CI/CD pipeline

