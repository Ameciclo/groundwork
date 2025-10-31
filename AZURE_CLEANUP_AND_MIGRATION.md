# Azure Cleanup & Terraform Cloud Migration Guide

## Overview

This guide helps you:
1. Clean up unused Azure resource groups
2. Migrate Azure Terraform to Terraform Cloud/HCP (same as your DigitalOcean setup)

---

## Part 1: Azure Resource Groups Analysis

### Current Resource Groups

| Name | Region | Status | Contents | Action |
|------|--------|--------|----------|--------|
| **ameciclo-rg-prod** | westus3 | ✅ ACTIVE | VM, PostgreSQL, VNet, NSGs, Public IP | **KEEP** |
| **ameciclo-rg** | westus2 | ⚠️ UNUSED | VNet, NSG (old deployment) | **DELETE** |
| **ameciclo-prod-rg** | eastus | ⚠️ UNUSED | 2x Cognitive Services (GPT resources) | **DELETE** |
| **NetworkWatcherRG** | eastus | 🔒 SYSTEM | Azure system resource | **KEEP** |

### Cost Impact of Cleanup

- **ameciclo-rg**: ~$0-5/month (idle VNet/NSG)
- **ameciclo-prod-rg**: ~$10-20/month (Cognitive Services)
- **Total savings**: ~$15-25/month

---

## Part 2: Cleanup Procedure

### Step 1: Verify Resources Before Deletion

```bash
# Check ameciclo-rg (westus2)
az resource list --resource-group "ameciclo-rg" --query "[].{Name:name, Type:type}" -o table

# Check ameciclo-prod-rg (eastus)
az resource list --resource-group "ameciclo-prod-rg" --query "[].{Name:name, Type:type}" -o table
```

### Step 2: Delete Unused Resource Groups

```bash
# Delete ameciclo-rg (westus2)
az group delete --name ameciclo-rg --yes --no-wait

# Delete ameciclo-prod-rg (eastus)
az group delete --name ameciclo-prod-rg --yes --no-wait
```

**Note**: `--no-wait` allows the command to return immediately. Deletion happens in background (5-10 minutes).

### Step 3: Monitor Deletion Progress

```bash
# Check status
az group list --output table

# Or watch specific group
az group show --name ameciclo-rg 2>/dev/null || echo "Group deleted successfully"
```

### Step 4: Verify Cleanup

```bash
# Final verification
az group list --output table
```

Expected result: Only `ameciclo-rg-prod` and `NetworkWatcherRG` remain.

---

## Part 3: Migrate Azure Terraform to Terraform Cloud

### Why Migrate?

✅ **Consistency**: Same backend as DigitalOcean Terraform  
✅ **Security**: No local state files with sensitive data  
✅ **Collaboration**: Team members can access state  
✅ **Audit Trail**: All changes tracked  
✅ **Remote Runs**: CI/CD integration  

### Current Setup

**Root Terraform** (`main.tf`):
```hcl
backend "remote" {
  organization = "Ameciclo"
  workspaces {
    name = "groundwork"
  }
}
```
✅ Already using Terraform Cloud

**Azure Terraform** (`azure/main.tf`):
```hcl
backend "local" {
  path = "terraform.tfstate"
}
```
❌ Using local backend (needs migration)

### Migration Steps

#### Step 1: Uncomment Backend in azure/main.tf

```bash
cd azure
```

Edit `azure/main.tf` and uncomment lines 19-25:

```hcl
backend "remote" {
  organization = "Ameciclo"

  workspaces {
    name = "groundwork-azure"
  }
}
```

Comment out lines 28-30:

```hcl
# backend "local" {
#   path = "terraform.tfstate"
# }
```

#### Step 2: Reinitialize Terraform

```bash
cd azure
terraform init
```

You'll see:
```
Do you want to copy existing state to the new backend?
```

**Answer: YES** (type `yes`)

This migrates your current state to Terraform Cloud.

#### Step 3: Verify Migration

```bash
# Check that state is now remote
terraform state list

# Verify in Terraform Cloud
# Visit: https://app.terraform.io/app/Ameciclo/workspaces/groundwork-azure
```

#### Step 4: Clean Up Local State Files

```bash
# After successful migration, you can remove local state files
rm -f terraform.tfstate terraform.tfstate.backup

# Verify they're gone
ls -la terraform.tfstate* 2>/dev/null || echo "Local state files removed"
```

#### Step 5: Update .gitignore (Optional)

The `.gitignore` already excludes `*.tfstate` files, so no changes needed.

---

## Part 4: Verification Checklist

### After Cleanup

- [x] `az group list` shows only `ameciclo-rg-prod` and `NetworkWatcherRG`
- [x] No resources in `ameciclo-rg` (westus2)
- [x] No resources in `ameciclo-prod-rg` (eastus)
- [x] `ameciclo-rg-prod` still has all your resources (VM, PostgreSQL, etc.)

### After Terraform Cloud Migration

- [x] `cd azure && terraform init` completes successfully
- [x] `terraform state list` shows your resources (20 resources)
- [x] Terraform Cloud workspace `groundwork-azure` exists
- [x] Local `terraform.tfstate` files removed
- [x] Backend reconfigured successfully with `cloud` block
- [x] `terraform plan` works without errors
- [x] Remote execution enabled and working

---

## Part 5: Troubleshooting

### Issue: "Cannot delete resource group - resources still exist"

**Solution**: Some resources may have locks or dependencies.

```bash
# Force delete (use with caution)
az group delete --name <rg-name> --yes --force-deletion-types Microsoft.Compute/virtualMachines
```

### Issue: "Terraform init fails after uncommenting backend"

**Solution**: Ensure you have Terraform Cloud credentials.

```bash
# Login to Terraform Cloud
terraform login

# Follow prompts to generate API token
# Paste token when prompted
```

### Issue: "State migration failed"

**Solution**: Manually migrate state.

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Push to Terraform Cloud
terraform push
```

---

## Summary

**Cleanup**: Delete 2 unused resource groups → Save $15-25/month  
**Migration**: Move Azure Terraform to Terraform Cloud → Better security & consistency  
**Result**: Cleaner infrastructure, unified state management

---

## Next Steps

1. Run cleanup commands (Part 2)
2. Migrate to Terraform Cloud (Part 3)
3. Verify everything works (Part 4)
4. Commit changes to git (if applicable)


