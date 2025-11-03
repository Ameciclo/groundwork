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

**Current Issue**: Storage and Container Registry are commented out

**Recommendation**: Uncomment and enable them for:
- Image storage (backups, exports)
- Container image registry
- File uploads

**Action**:
```hcl
# In storage.tf and container_registry.tf:
# - Uncomment all resources
# - Update subnet references to use K3s subnet
# - Add proper network rules
```

---

### 3. **Add Terraform Locals for DRY Code** ⭐ MEDIUM PRIORITY

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

**Recommendation**: Add Azure Monitor resources

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

---

### 7. **Add Backup & Disaster Recovery** ⭐ MEDIUM PRIORITY

**Current**: PostgreSQL has 7-day backup retention

**Recommendation**: Consider:
- Increase backup retention to 30 days
- Enable geo-redundant backups (if budget allows)
- Add VM backup policy

```hcl
# In database.tf:
backup_retention_days        = 30  # Increase from 7
geo_redundant_backup_enabled = true  # Add this
```

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

**Current Monthly Costs**:
- PostgreSQL B2s: ~$24.70
- K3s VM (B2as_v2): ~$40-50
- Storage/Networking: ~$5-10
- **Total**: ~$70-85/month

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

### Phase 1 (Do First)
1. ✅ Remove main VM (vm.tf) - Save $40/month
2. ✅ Update outputs.tf to remove main VM outputs
3. ✅ Test with `terraform plan`

### Phase 2 (Do Next)
1. ✅ Uncomment Storage Account
2. ✅ Uncomment Container Registry
3. ✅ Update network rules for K3s subnet

### Phase 3 (Nice to Have)
1. ✅ Create locals.tf for DRY code
2. ✅ Add monitoring
3. ✅ Restrict SSH to specific IPs
4. ✅ Increase backup retention

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

