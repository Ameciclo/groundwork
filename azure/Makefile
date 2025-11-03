.PHONY: help init plan apply destroy fmt validate clean lint docs

# Default target
help:
	@echo "Ameciclo Azure Terraform Makefile"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make init       - Initialize Terraform"
	@echo "  make plan       - Plan infrastructure changes"
	@echo "  make apply      - Apply infrastructure changes"
	@echo "  make destroy    - Destroy infrastructure"
	@echo "  make fmt        - Format Terraform files"
	@echo "  make validate   - Validate Terraform configuration"
	@echo "  make lint       - Lint Terraform files (requires tflint)"
	@echo "  make clean      - Clean Terraform cache"
	@echo "  make docs       - Generate documentation"
	@echo "  make state      - Show Terraform state"
	@echo "  make output     - Show Terraform outputs"
	@echo ""

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Plan infrastructure changes
plan:
	@echo "Planning infrastructure changes..."
	terraform plan -out=tfplan

# Apply infrastructure changes
apply:
	@echo "Applying infrastructure changes..."
	@if [ -f tfplan ]; then \
		terraform apply tfplan; \
		rm tfplan; \
	else \
		echo "No plan file found. Run 'make plan' first."; \
	fi

# Destroy infrastructure
destroy:
	@echo "WARNING: This will destroy all infrastructure!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy; \
	else \
		echo "Destroy cancelled."; \
	fi

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Lint Terraform files (requires tflint)
lint:
	@echo "Linting Terraform files..."
	@command -v tflint >/dev/null 2>&1 || { echo "tflint not installed. Install it with: brew install tflint"; exit 1; }
	tflint

# Clean Terraform cache
clean:
	@echo "Cleaning Terraform cache..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f crash.log

# Generate documentation
docs:
	@echo "Generating documentation..."
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not installed. Install it with: brew install terraform-docs"; exit 1; }
	terraform-docs markdown . > README_AUTO.md

# Show Terraform state
state:
	@echo "Terraform state:"
	terraform state list

# Show Terraform outputs
output:
	@echo "Terraform outputs:"
	terraform output

# Full workflow
all: fmt validate plan

# Development workflow
dev: fmt validate plan

# Production workflow (requires approval)
prod: fmt validate plan apply

# Quick check
check: fmt validate lint

# Show version
version:
	@echo "Terraform version:"
	terraform version
	@echo ""
	@echo "Azure CLI version:"
	az --version | head -1

