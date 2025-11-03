# Azure Terraform Structure Review & Recommendations

## ✅ Current Status

**Azure Resources**: Clean! Only default NetworkWatchers exist (auto-created by Azure, safe to ignore)

**Terraform Structure**: Well-organized with good separation of concerns

---

## 📋 Current Architecture ✅ OPTIMIZED

### Single VNet Architecture

**Current (Consolidated)**:
1. **Resource Groups** (1)
   - `ameciclo-rg` - All resources ✅

2. **Networking** (CONSOLIDATED)
   - 1 Virtual Network: `ameciclo-vnet` (10.10.0.0/16) ✅
   - 2 Subnets:
     * K3s subnet (10.10.1.0/24) ✅
     * Database subnet (10.10.2.0/24) ✅
   - 2 Network Security Groups (K3s, Database) ✅
   - No VNet Peering (not needed) ✅

3. **Database**
   - PostgreSQL Flexible Server (B2s tier, ~$24.70/month)
   - 2 Databases (atlas, kong)
   - Private DNS Zone linked to single VNet ✅

4. **Compute**
   - 1 K3s VM (ameciclo-k3s-vm) ✅
   - Public IP (Static)
   - Network Interface

5. **Storage**
   - Storage Account (enabled)
   - Using GHCR for images (no Container Registry)

---

## 🎯 Recommendations

### 0. **Consolidate to Single VNet** ⭐ CRITICAL PRIORITY
- [x] **DONE** - Merged main VNet and K3s VNet into one

**What Was Done**:
- ✅ Removed separate K3s VNet (`ameciclo-k3s-vnet`)
- ✅ Removed K3s resource group (`ameciclo-k3s-rg`)
- ✅ Consolidated to single VNet (`ameciclo-vnet` 10.10.0.0/16)
- ✅ Created 2 subnets:
  - K3s subnet (10.10.1.0/24)
  - Database subnet (10.10.2.0/24)
- ✅ Moved K3s VM from k3s.tf to network.tf
- ✅ Moved K3s NSG from k3s.tf to network.tf
- ✅ Removed VNet peering (no longer needed)
- ✅ Updated database.tf to use single VNet
- ✅ Removed duplicate DNS zone links
- ✅ Deleted k3s.tf file
- ✅ Updated variables.tf (removed K3s-specific variables)
- ✅ Updated locals.tf (removed K3s-specific variables)
- ✅ Fixed data_sources.tf (removed invalid arguments)

**Benefits Achieved**:
- ✅ Simpler architecture
- ✅ Removed VNet peering complexity
- ✅ Single private DNS zone
- ✅ Easier to manage
- ✅ Slightly lower costs
- ✅ Terraform plan validates successfully

---

### 1. **Consolidate to Single K3s VM** ⭐ HIGH PRIORITY
- [x] **DONE** - Remove the main VM and use only K3s VM

**Current Issue**: You have TWO VMs:
- `ameciclo-vm` (main VM) - Not being used
- `ameciclo-k3s-vm` (K3s VM) - The actual cluster

**Recommendation**: Remove the main VM and use only K3s VM

**Benefits**:
- ✅ Reduce costs (~$30-40/month savings)
- ✅ Simpler architecture
- ✅ Easier to manage
- ✅ K3s can run all services (Kong, Atlas, Kestra)

**Action**:
```bash
# Delete these files:
# - azure/vm.tf (remove main VM)
# - Keep only K3s VM in k3s.tf

# Update outputs.tf to remove main VM outputs
# Update variables.tf to remove main VM variables
```

---

### 2. **Enable Storage Account & Container Registry** ⭐ MEDIUM PRIORITY
- [x] **DONE** - Enable Storage Account (using GHCR for images)
- [x] **DONE** - Remove Container Registry (using GHCR instead)

**Current Issue**: Storage and Container Registry are commented out

**Recommendation**:
- ✅ Enable Storage Account for backups and file uploads
- ✅ Remove Container Registry (using GitHub Container Registry instead)

**Action**:
```hcl
# In storage.tf:
# - Uncomment all resources
# - Update subnet references to use K3s subnet
# - Add proper network rules

# In container_registry.tf:
# - DELETE (using GHCR instead)
```

---

### 3. **Add Terraform Locals for DRY Code** ⭐ MEDIUM PRIORITY
- [x] **DONE** - Create locals.tf for common values

**Current Issue**: Hardcoded values repeated across files

**Recommendation**: Create `locals.tf` for common values

```hcl
# locals.tf
locals {
  project_name = "ameciclo"
  environment  = "production"

  # Naming conventions
  vm_name_prefix = "${local.project_name}-${local.environment}"

  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
}
```

**Benefits**:
- ✅ Single source of truth
- ✅ Easier to maintain
- ✅ Consistent naming

---

### 4. **Add terraform.tfvars.example with Real Defaults** ⭐ LOW PRIORITY
- [x] **DONE** - Create terraform.tfvars.example with sensible defaults

**Current Issue**: `terraform.tfvars.example` is missing

**Recommendation**: Create it with sensible defaults

```hcl
# terraform.tfvars.example
region                    = "eastus"
environment               = "production"
postgresql_version        = "16"
postgresql_sku_name       = "B_Standard_B2s"
vm_size                   = "Standard_B2as_v2"
```

---

### 5. **Add Data Sources for Existing Resources** ⭐ LOW PRIORITY
- [x] **DONE** - Add data sources for Azure images and client config

**Recommendation**: Use data sources for Azure images

```hcl
# Instead of hardcoding image details:
data "azurerm_client_config" "current" {}

data "azurerm_image" "ubuntu" {
  name_regex          = "Ubuntu-22.04-LTS"
  resource_group_name = "UbuntuImages"
}
```

---

### 6. **Add Monitoring & Alerts** ⭐ MEDIUM PRIORITY
- [ ] **NOT DONE** - Optional (adds ~$10-15/month cost)

**Cost Impact**: +$10-15/month for Log Analytics Workspace

**Recommendation**: Add Azure Monitor resources for:
- PostgreSQL performance monitoring
- VM health checks
- Alert rules for critical events

```hcl
# monitoring.tf
resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  name               = "postgresql-diagnostics"
  target_resource_id = azurerm_postgresql_flexible_server.postgresql.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "PostgreSQLLogs"
  }
}
```

**Decision**: Skip for now (can add later if needed)

---

### 7. **Add Backup & Disaster Recovery** ⭐ MEDIUM PRIORITY
- [ ] **NOT DONE** - Optional (adds ~$5-10/month cost)

**Cost Impact**: +$5-10/month for geo-redundant backups

**Current**: PostgreSQL has 7-day backup retention

**Recommendation**: Consider:
- Increase backup retention to 30 days (+$2-3/month)
- Enable geo-redundant backups (+$3-7/month)
- Add VM backup policy (+$5-10/month)

```hcl
# In database.tf:
backup_retention_days        = 30  # Increase from 7 (+$2-3/month)
geo_redundant_backup_enabled = true  # Add this (+$3-7/month)
```

**Decision**: Keep current 7-day retention (cost-effective for dev/staging)

---

### 8. **Add Network Security Improvements** ⭐ MEDIUM PRIORITY

**Current**: SSH open to `*` (0.0.0.0/0)

**Recommendation**: Restrict SSH to specific IPs

```hcl
# Add variable for allowed SSH IPs
variable "allowed_ssh_ips" {
  description = "IPs allowed to SSH"
  type        = list(string)
  default     = ["YOUR_IP/32"]  # Restrict to your IP
}

# Update NSG rule:
source_address_prefix = var.allowed_ssh_ips[0]
```

---

### 9. **Add Outputs for K3s Setup** ⭐ LOW PRIORITY

**Recommendation**: Add helpful outputs

```hcl
# In outputs.tf:
output "k3s_setup_command" {
  value = "ansible-playbook -i ansible/k3s-azure-inventory.yml ansible/k3s-azure-playbook.yml"
}

output "kubeconfig_path" {
  value = "~/.kube/config"
}
```

---

### 10. **Add Cost Estimation** ⭐ LOW PRIORITY
- [x] **DONE** - Document cost estimation

**Current Monthly Costs** (After removing main VM):
- PostgreSQL B2s: ~$24.70
- K3s VM (B2as_v2): ~$40-50
- Storage Account (LRS): ~$0.50-2.00
- Networking/IPs: ~$5-10
- **Total**: ~$70-85/month

**Optional Add-ons**:
- Monitoring (Log Analytics): +$10-15/month
- Geo-redundant backups: +$3-7/month
- Extended backup retention: +$2-3/month

**Recommendation**: Add cost tags for tracking

```hcl
# In variables.tf:
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "ameciclo-infrastructure"
}
```

---

## 🚀 Priority Action Items

### Phase 1 (Do First) - COST OPTIMIZATION ✅ DONE
- [x] Remove main VM (vm.tf) - Save $40/month
- [x] Update outputs.tf to remove main VM outputs
- [x] Update variables.tf to remove main VM variables
- [x] Test with `terraform plan`

### Phase 2 (Do Next) - INFRASTRUCTURE ✅ DONE
- [x] Uncomment Storage Account
- [x] Remove Container Registry (using GHCR)
- [x] Update network rules for K3s subnet
- [x] Create locals.tf for DRY code
- [x] Create terraform.tfvars.example
- [x] Add data sources for Azure images

### Phase 3 (CRITICAL) - NETWORK CONSOLIDATION ✅ COMPLETE
- [x] Consolidate to single VNet (10.10.0.0/16)
- [x] Move K3s VM from k3s.tf to network.tf
- [x] Remove k3s.tf file
- [x] Remove VNet peering
- [x] Update database.tf to use single VNet
- [x] Remove duplicate resource group
- [x] Test with `terraform plan` ✅ VALID

### Phase 4 (Nice to Have) - SECURITY & MONITORING
- [ ] Restrict SSH to specific IPs
- [ ] Add monitoring (optional, +$10-15/month)
- [ ] Increase backup retention (optional, +$2-3/month)
- [ ] Enable geo-redundant backups (optional, +$3-7/month)

---

## 📊 File Organization

**Final Structure** ✅ (After Consolidation):
```
azure/
├── main.tf                              # Provider config
├── locals.tf                            # DRY code ✅
├── data_sources.tf                      # Data sources ✅
├── variables.tf                         # All variables ✅
├── outputs.tf                           # All outputs ✅
├── terraform.tfvars.example             # Example values ✅
├── resource_group.tf                    # Single resource group ✅
├── network.tf                           # Single VNet + 2 subnets + K3s VM + 2 NSGs ✅
├── database.tf                          # PostgreSQL (single VNet) ✅
├── storage.tf                           # Storage Account ✅
├── TERRAFORM_REVIEW_AND_RECOMMENDATIONS.md  # This document
├── IMPLEMENTATION_SUMMARY.md            # Implementation summary
├── CREDENTIALS_QUICK_START.md           # Credentials guide
├── GET_CREDENTIALS.md                   # Detailed credentials guide
└── setup-credentials.sh                 # Automated setup script
```

**Architecture Summary**:
- ✅ Single Resource Group: `ameciclo-rg`
- ✅ Single VNet: `ameciclo-vnet` (10.10.0.0/16)
  - K3s Subnet: `k3s-subnet` (10.10.1.0/24)
  - Database Subnet: `database-subnet` (10.10.2.0/24)
- ✅ Single K3s VM: `ameciclo-k3s-vm` (B2as_v2)
- ✅ PostgreSQL: `ameciclo-postgres` (B2s tier)
- ✅ Storage Account: `ameciclostorage` (LRS)
- ✅ 2 NSGs: K3s NSG + Database NSG
- ✅ No VNet Peering (single VNet)

---

## ✅ Summary

**What's Good** ✅:
- ✅ Single consolidated VNet (10.10.0.0/16)
- ✅ Single resource group (ameciclo-rg)
- ✅ Single K3s VM (cost optimized)
- ✅ 2 subnets (K3s + Database)
- ✅ 2 NSGs (K3s + Database)
- ✅ No VNet peering (simplified)
- ✅ Storage Account enabled
- ✅ DRY code with locals.tf
- ✅ Comprehensive terraform.tfvars.example
- ✅ Clean separation of concerns
- ✅ Proper tagging strategy
- ✅ Private database access

**Completed Phases** ✅:
1. ✅ Phase 1: Remove main VM (DONE)
2. ✅ Phase 2: Enable Storage & DRY code (DONE)
3. ✅ Phase 3: Consolidate VNets (DONE)

**Optional Enhancements** (Phase 4):
- [ ] Restrict SSH access to specific IPs (security)
- [ ] Add monitoring (optional, +$10-15/month)
- [ ] Increase backup retention (optional, +$2-3/month)
- [ ] Enable geo-redundant backups (optional, +$3-7/month)

