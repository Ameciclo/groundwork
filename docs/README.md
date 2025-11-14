# Documentation

This directory contains documentation for the Ameciclo infrastructure and applications.

## Infrastructure Documentation

### Getting Started
- [Main README](../README.md) - Overview and quick start guide
- [Pulumi Infrastructure](../infrastructure/pulumi/README.md) - Detailed infrastructure setup
- [Ansible Provisioning](../automation/ansible/README.md) - K3s VM provisioning guide
- [Ansible Quick Start](../automation/ansible/QUICKSTART.md) - Step-by-step provisioning

### Local Development
- [k9s Setup](k9s-setup.md) - Access cluster with k9s via Tailscale

### Kubernetes Concepts
- [Kubernetes for Docker Compose Users](KUBERNETES_FOR_DOCKER_COMPOSE_USERS.md) - Learn Kubernetes if you know Docker Compose
- [What is an Ingress?](WHAT_IS_INGRESS.md) - Understanding Kubernetes networking

### GitOps & Deployment
- [ArgoCD Sync Explained](ARGOCD_SYNC_EXPLAINED.md) - How GitOps deployments work
- [Notifications Setup](NOTIFICATIONS_SETUP.md) - Telegram notifications configuration

### Migration & Troubleshooting
- [Traefik Migration](traefik-migration.md) - Historical: K3s Traefik to ArgoCD-managed migration

## Application Documentation

### Helm Charts
- **Strapi**: Headless CMS for content management
- **Atlas**: Traffic data APIs and documentation
- **Traefik**: Ingress controller with automatic HTTPS
- **ArgoCD**: GitOps continuous deployment

### Application Structure
```
kubernetes/
├── applications/              # Custom applications
│   ├── strapi/               # CMS application
│   └── atlas/                # Data APIs
│       ├── docs/            # Documentation site
│       └── traffic-deaths/  # Traffic data API
├── infrastructure/           # Platform components
│   ├── traefik/             # Ingress controller
│   └── argocd-config/       # GitOps configuration
└── environments/             # Environment-specific configs
    └── prod/                # Production ArgoCD applications
```

## Quick Reference

### Common Commands

```bash
# Infrastructure
cd pulumi/infrastructure
pulumi stack output          # View infrastructure outputs
pulumi up                   # Update infrastructure

# Applications
kubectl get applications -n argocd    # View ArgoCD apps
kubectl get pods -A                  # View all pods
kubectl logs -f deployment/strapi -n strapi  # View app logs

# Access cluster
ssh azureuser@$(pulumi stack output k3sPublicIp)
```

### Useful Links
- [Pulumi Azure Native Provider](https://www.pulumi.com/registry/packages/azure-native/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [K3s Documentation](https://docs.k3s.io/)
