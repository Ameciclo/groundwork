# Groundwork - Ameciclo Infrastructure

This repository contains the Terraform configuration for provisioning and managing Ameciclo's cloud infrastructure on DigitalOcean.

## Overview

Groundwork sets up the following resources on DigitalOcean:

- Virtual Private Cloud (VPC) for network isolation
- PostgreSQL database cluster
- Web server droplets (virtual machines)
- S3-compatible object storage (Spaces)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- DigitalOcean account with API token
- DigitalOcean Spaces access keys
- SSH key uploaded to DigitalOcean

## Configuration

Create a `terraform.tfvars` file with the following variables:

```hcl
digitalocean_token             = "your_digitalocean_api_token"
digitalocean_spaces_access_key = "your_spaces_access_key"
digitalocean_spaces_secret_key = "your_spaces_secret_key"
```

## Usage

Initialize Terraform:

```bash
terraform init
```

Plan the infrastructure changes:

```bash
terraform plan
```

Apply the changes:

```bash
terraform apply
```

Destroy the infrastructure when no longer needed:

```bash
terraform destroy
```

## Infrastructure Components

### Docker Configurations

The `docker/` directory contains Docker Compose files for services that run on the infrastructure:

- `docker/portainer/` - Portainer container management UI
- See `docker/README.md` for more details on Docker configurations

### VPC

A private network with the IP range `10.10.0.0/16` in the `nyc3` region.

### Database

PostgreSQL v16 database cluster with the following specifications:
- Size: 1 vCPU, 1GB RAM
- Single node configuration
- Connected to the private VPC network
- PostGIS extension enabled for geospatial data support

### Droplets

Ubuntu 24.04 virtual machines with:
- 2 vCPUs, 4GB RAM (AMD)
- IPv6 enabled
- Connected to the private VPC network

### Object Storage

S3-compatible object storage bucket for storing application assets and data.

## Remote State Management

This project uses Terraform Cloud for remote state management under the "Ameciclo" organization and "groundwork" workspace.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

[Specify the license here]
