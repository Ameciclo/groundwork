.PHONY: help install build preview up refresh destroy output clean login

# Default target
help:
	@echo "Ameciclo Azure Pulumi Makefile"
	@echo "==============================="
	@echo ""
	@echo "Available targets:"
	@echo "  make install    - Install npm dependencies"
	@echo "  make build      - Build TypeScript code"
	@echo "  make preview    - Preview infrastructure changes"
	@echo "  make up         - Deploy infrastructure"
	@echo "  make refresh    - Refresh stack state"
	@echo "  make destroy    - Destroy infrastructure"
	@echo "  make output     - Show stack outputs"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make login      - Login to Pulumi"
	@echo ""

# Install dependencies
install:
	@echo "Installing dependencies..."
	npm install

# Build TypeScript
build:
	@echo "Building TypeScript..."
	npm run build

# Preview changes
preview: build
	@echo "Previewing infrastructure changes..."
	pulumi preview

# Deploy infrastructure
up: build
	@echo "Deploying infrastructure..."
	pulumi up

# Refresh stack state
refresh:
	@echo "Refreshing stack state..."
	pulumi refresh

# Destroy infrastructure
destroy:
	@echo "WARNING: This will destroy all infrastructure!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		pulumi destroy; \
	else \
		echo "Destroy cancelled."; \
	fi

# Show outputs
output:
	@echo "Stack outputs:"
	pulumi stack output

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	rm -rf node_modules/
	rm -f *.js *.js.map *.d.ts

# Login to Pulumi
login:
	@echo "Logging in to Pulumi..."
	pulumi login

# Quick check
check: build preview

# Full workflow
all: install build preview

