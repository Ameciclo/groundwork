# Documentation

This directory contains documentation for the Ameciclo infrastructure and applications.

## Infrastructure Documentation

### Getting Started
- [Main README](../README.md) - Overview and quick start guide
- [Pulumi Infrastructure](../pulumi/infrastructure/README.md) - Detailed infrastructure setup

### Kubernetes Concepts
- [Kubernetes for Docker Compose Users](KUBERNETES_FOR_DOCKER_COMPOSE_USERS.md) - Learn Kubernetes if you know Docker Compose
- [What is an Ingress?](WHAT_IS_INGRESS.md) - Understanding Kubernetes networking

### GitOps & Deployment
- [ArgoCD Sync Explained](ARGOCD_SYNC_EXPLAINED.md) - How GitOps deployments work
- [Notifications Setup](NOTIFICATIONS_SETUP.md) - Telegram notifications configuration

## Application Documentation

### Helm Charts
- **Strapi**: Headless CMS for content management
- **Atlas**: Traffic data APIs and documentation
- **Traefik**: Ingress controller with automatic HTTPS
- **ArgoCD**: GitOps continuous deployment

### Application Structure
```
helm/
├── charts/                    # Application definitions
│   ├── strapi/               # CMS application
│   ├── atlas/                # Data APIs
│   │   ├── docs/            # Documentation site
│   │   └── traffic-deaths/  # Traffic data API
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
