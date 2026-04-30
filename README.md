# Groundwork — Ameciclo Infrastructure

Cloud infrastructure for Ameciclo: **Pulumi + Azure + Coolify**.

A single Azure VM runs [Coolify](https://coolify.io), which manages Dockerized applications (currently Strapi). Persistent state — PostgreSQL and media — lives in managed Azure services so the VM is essentially stateless and can be replaced without data loss.

## Quick start

```bash
cd infrastructure/pulumi
npm install
pulumi up

# VM provisions itself with Coolify via cloud-init (~5-10 min after pulumi up)
# Coolify UI: https://coolify.az.ameciclo.org
ssh azureuser@$(pulumi stack output coolifyPublicIp)
```

## What gets deployed

### Azure (managed by Pulumi, in `infrastructure/pulumi/`)

- **Virtual Network** — `10.10.0.0/16`, with VM subnet `10.10.1.0/24` and database subnet `10.10.2.0/24`
- **PostgreSQL Flexible Server** — private (VNet-only), with databases for `strapi`, `atlas`, `zitadel`
- **VM** — Ubuntu 22.04 LTS, Standard_B4as_v2 (4 vCPU, 16 GB), self-installs Coolify via cloud-init
- **Blob Storage** — `media`, `backups`, `logs` containers
- **Network Security Group** — only 22 / 80 / 443 open

### On the VM (managed by Coolify)

- **Coolify** itself, exposed at `https://coolify.az.ameciclo.org` via its built-in Traefik with Let's Encrypt
- **Strapi** (CMS) — pulled from `ghcr.io/ameciclo/strapi:latest`, exposed at `https://strapi.az.ameciclo.org`. Connects to the Azure Postgres `strapi` database and Azure Blob `media` container.

Other apps (Atlas, Zitadel, Passbolt) are not currently deployed. Their databases still exist in Azure Postgres and can be used if/when those apps are revived through Coolify.

## Repository layout

```
groundwork/
├── azure/scripts/                  # One-off scripts (Postgres user provisioning)
└── infrastructure/pulumi/          # Pulumi stack: Azure VNet, VM, Postgres, Storage
    ├── index.ts                    # Resources (network, postgres, storage)
    ├── vm.ts                       # VM with Coolify cloud-init
    ├── esc/                        # Pulumi ESC environments
    └── ...
```

## Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) v3.139+
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (logged in)
- SSH key pair
- Pulumi Cloud account

## Initial setup

```bash
cd infrastructure/pulumi
npm install

# Set the SSH public key the VM should accept
pulumi config set --secret adminSshPublicKey "$(cat ~/.ssh/id_rsa.pub)"

# Initialize stack (only needed once per environment)
pulumi stack init ameciclo/prod

# Deploy
pulumi up
```

After `pulumi up` completes, the VM takes ~5–10 minutes to finish cloud-init and bring up Coolify. SSH in to check progress:

```bash
ssh azureuser@$(pulumi stack output coolifyPublicIp)
cloud-init status
sudo docker ps
```

Once Coolify is running, set its public domain via the UI (initial access via SSH tunnel: `ssh -L 8000:localhost:8000 -L 6001:localhost:6001 -L 6002:localhost:6002 azureuser@<vm-ip>`), then everything afterwards is via `https://coolify.az.ameciclo.org`.

## DNS

DNS is hosted at Cloudflare. Records currently in use:

| Hostname | Type | Target | Cloudflare proxy |
|---|---|---|---|
| `coolify.az.ameciclo.org` | A | VM public IP | DNS-only (grey) |
| `strapi.az.ameciclo.org` | A | VM public IP | DNS-only (grey) |

Coolify-provided Traefik issues Let's Encrypt certs via HTTP-01 challenge, which requires direct (DNS-only) access. Cloudflare proxy can be enabled later if you want CDN/WAF in front, but Let's Encrypt renewal needs to be reconfigured for DNS-01 first.

## Adding new apps in Coolify

1. In Coolify UI: **+ Add Resource** → **Docker Image** (or **Public/Private Repository** for git-based)
2. Configure ports, domain, env vars
3. For automated deploys on git push: get the deploy webhook URL from the resource's **Webhooks** tab and add a `curl` step to the app's CI workflow

## Cost estimate

| Service | Tier | Monthly |
|---|---|---|
| PostgreSQL | Standard_B2s | ~$24 |
| VM | Standard_B4as_v2 | ~$70 |
| Storage | Standard LRS | ~$2 |
| Networking | Standard | ~$8 |
| **Total** | | **~$104** |

(Estimates for West US 3, in USD. Actuals will vary.)

## Security

- PostgreSQL is private (VNet-only)
- SSH is key-auth only
- NSG opens only 22 / 80 / 443
- Secrets are stored in Pulumi ESC (infrastructure) and Coolify per-app env vars (applications)
- HTTPS is automatic for any domain configured on a Coolify resource

## Common operations

```bash
# Infrastructure
cd infrastructure/pulumi
pulumi stack output                           # All exports
pulumi stack output coolifyPublicIp           # VM public IP
pulumi up                                     # Apply changes
pulumi destroy                                # ⚠️ tear everything down

# VM
ssh azureuser@$(pulumi stack output coolifyPublicIp)
sudo docker ps                                # Running containers
sudo journalctl -u docker --since '1 hour ago' # Docker daemon logs
```

## Replacing the VM

The VM is stateless. To replace it (OS upgrade, fresh install, etc.):

```bash
# Edit infrastructure/pulumi/vm.ts (e.g. cloud-init changes, image version)
pulumi up
# Pulumi recreates the VM in place; NIC + Public IP are retained,
# so DNS doesn't need to change.
```

The previous VM's data (Coolify database, application configs) is *not* preserved. Re-run Coolify's onboarding and re-add applications. Application data (Postgres, Blob) is unaffected.

---

**Built by Ameciclo** | [ameciclo.org](https://ameciclo.org) | [GitHub](https://github.com/Ameciclo)
