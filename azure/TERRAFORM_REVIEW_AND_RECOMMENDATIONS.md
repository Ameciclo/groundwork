# Azure Terraform Structure Review & Recommendations

## ✅ Current Status

**Azure Resources**: Clean! Only default NetworkWatchers exist (auto-created by Azure, safe to ignore)

**Terraform Structure**: Well-organized with good separation of concerns

---

## 📋 Current Architecture

### Resources Being Created

1. **Resource Groups** (2)
   - `ameciclo-rg` - Main resources
   - `ameciclo-k3s-rg` - K3s cluster

2. **Networking**
   - 2 Virtual Networks (main + K3s)
   - 3 Subnets (VM, Database, K3s)
   - VNet Peering (main ↔ K3s)
   - 3 Network Security Groups with rules

3. **Database**
   - PostgreSQL Flexible Server (B2s tier, ~$24.70/month)
   - 2 Databases (atlas, kong)
   - Private DNS Zone for secure access

4. **Compute**
   - 2 VMs (main VM + K3s VM)
   - Public IPs for both
   - Network Interfaces

5. **Storage & Registry** (Commented out)
   - Storage Account (disabled)
   - Container Registry (disabled)

---

## 🎯 Recommendations

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

### Phase 1 (Do First) - COST OPTIMIZATION
- [x] Remove main VM (vm.tf) - Save $40/month
- [x] Update outputs.tf to remove main VM outputs
- [x] Update variables.tf to remove main VM variables
- [x] Test with `terraform plan`

### Phase 2 (Do Next) - INFRASTRUCTURE
- [x] Uncomment Storage Account
- [x] Remove Container Registry (using GHCR)
- [x] Update network rules for K3s subnet
- [x] Create locals.tf for DRY code
- [x] Create terraform.tfvars.example
- [x] Add data sources for Azure images

### Phase 3 (Nice to Have) - SECURITY & MONITORING
- [ ] Restrict SSH to specific IPs
- [ ] Add monitoring (optional, +$10-15/month)
- [ ] Increase backup retention (optional, +$2-3/month)
- [ ] Enable geo-redundant backups (optional, +$3-7/month)

---

## 📊 File Organization

**Current Structure** (Good):
```
azure/
├── main.tf              # Provider config
├── variables.tf         # All variables
├── outputs.tf           # All outputs
├── resource_group.tf    # Resource groups
├── network.tf           # VNets, subnets, NSGs
├── vm.tf                # Main VM (REMOVE)
├── k3s.tf               # K3s VM
├── database.tf          # PostgreSQL
├── storage.tf           # Storage (commented)
└── container_registry.tf # Registry (commented)
```

**Recommended Additions**:
```
azure/
├── locals.tf            # Common values
├── monitoring.tf        # Azure Monitor
├── security.tf          # Security groups, policies
└── terraform.tfvars.example  # Example values
```

---

## ✅ Summary

**What's Good**:
- ✅ Clean separation of concerns
- ✅ Good use of variables
- ✅ Proper tagging strategy
- ✅ Private database access
- ✅ VNet peering configured

**What to Improve**:
- ⚠️ Remove unused main VM
- ⚠️ Enable Storage & Registry
- ⚠️ Add locals for DRY code
- ⚠️ Restrict SSH access
- ⚠️ Add monitoring

**Next Steps**:
1. Run `terraform plan` to verify current state
2. Remove main VM (Phase 1)
3. Enable Storage & Registry (Phase 2)
4. Add monitoring (Phase 3)

