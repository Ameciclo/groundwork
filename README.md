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
- **PostgreSQL Flexible Server** — private (VNet-only), with databases for `strapi`, `atlas`, `ameciclo`
- **VM** — Ubuntu 22.04 LTS, Standard_B4as_v2 (4 vCPU, 16 GB), self-installs Coolify via cloud-init
- **Blob Storage** — `media`, `backups`, `logs` containers
- **Network Security Group** — only 22 / 80 / 443 open

### On the VM (managed by Coolify)

- **Coolify** itself, exposed at `https://coolify.az.ameciclo.org` via its built-in Traefik with Let's Encrypt
- **Strapi** (CMS) — pulled from `ghcr.io/ameciclo/strapi:latest`, exposed at `https://strapi.az.ameciclo.org`. Connects to the Azure Postgres `strapi` database and Azure Blob `media` container.

Atlas is not currently deployed; its database still exists in Azure Postgres and can be used if the app is revived through Coolify.

### Databases and users

Databases are `azure.dbforpostgresql.Database` resources in `index.ts`. Login roles are created with the `createDbRole()` helper (`@pulumi/postgresql`), which generates a password and grants access. Roles must always stay declared in `index.ts`: removing one makes the next `pulumi up` drop it from the database.

### Extensions

Extensions are declared in `index.ts` too, in two parts: the `azure.extensions` server parameter (the allow-list, `postgresql-pub-extensions`) and one `postgresql.Extension` per database (`CREATE EXTENSION`, which also needs the tunnel below). Today that is **PostGIS** on the `ameciclo` database.

`azure.extensions` is a single comma-separated list and Pulumi sets the whole value, so to add another extension, first read the current list and keep what is in it:

```bash
az postgres flexible-server parameter show -g ameciclo-rg-prod \
  --server-name ameciclo-postgres-pub --name azure.extensions --query value -o tsv
```

The `Extension` resources use `retainOnDelete`, so removing one from the program never drops the extension from the database.

The provider only connects to Postgres when a role or grant actually changes. Unrelated `pulumi up`/`preview` runs (and CI) don't need a tunnel. To add or change a role, open the tunnel and pass an AAD token:

```bash
# terminal 1: tunnel (see docs/connecting.md)
az ssh vm -g ameciclo-rg-prod -n ameciclo-coolify-vm -- \
  -N -L 15433:ameciclo-postgres-pub.postgres.database.azure.com:5432

# terminal 2, from infrastructure/pulumi
PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv) pulumi up
pulumi stack output amecicloPubDbPassword --show-secrets   # a role's password
```

The provider signs in as the `TI Ameciclo` group using a short-lived AAD token, not a stored password.

## Repository layout

```
groundwork/
├── docs/connecting.md              # Tested VM/DB connection guide
├── docs/postgres-migration.md      # Runbook: move to the public Postgres server
├── .github/workflows/              # CI (pulumi preview on PRs)
└── infrastructure/pulumi/          # Pulumi stack: Azure VNet, VM, Postgres, Storage
    ├── index.ts                    # Resources (network, postgres, storage)
    ├── vm.ts                       # VM with Coolify cloud-init
    ├── scripts/                    # DB user provisioning, local setup
    └── ...
```

## Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) v3.139+
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (logged in)
- SSH key pair
- Membership in the `TI Ameciclo` Entra ID group (for `az storage`/`az ssh`/AAD-based DB access — see [Access](#access))

State and secrets are self-managed (no Pulumi Cloud account needed): state lives in the `pulumi-state` container of the `ameciclostorprod` Azure Storage account, and secrets use Pulumi's `passphrase` provider with an **empty passphrase**, so there is no shared secret to keep or lose (see [Security](#security)).

## Initial setup

```bash
cd infrastructure/pulumi
npm install

# Log in to the self-managed state backend (one-time per machine)
pulumi login "azblob://pulumi-state?storage_account=ameciclostorprod"

# The stack uses an empty passphrase (see Security). The variable must still be
# *set* (to empty) in every shell. mise sets it for you via .mise.toml.
export PULUMI_CONFIG_PASSPHRASE=""

# Select the existing stack (already initialized — don't `stack init` a new one)
pulumi stack select prod

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

### Configuration

```bash
pulumi config set projectName my-project     # default: ameciclo
pulumi config set location westus2           # default: westus3
pulumi config set environment staging        # default: production
```

### Outputs

```bash
pulumi stack output                # all of them
pulumi stack output coolifyPublicIp
```

| Output | Description |
|---|---|
| `coolifyPublicIp` / `coolifySshCommand` | VM public IP / ready-to-use SSH command |
| `postgresqlPubServerFqdn` | Database server FQDN |
| `strapiPubDbPassword` / `atlasPubDbPassword` / `amecicloPubDbPassword` | App role passwords (`--show-secrets` to reveal) |
| `resourceGroupName` | Azure resource group |
| `storageAccountName` | Blob storage account |

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
- SSH accepts a shared keypair (`adminSshPublicKey`) *and* Azure AD login (see [Access](#access)) — the NSG still allows SSH from any source IP, so treat this as a known gap, not a solved one
- NSG opens only 22 / 80 / 443
- Infrastructure secrets (SSH key, DB password) are encrypted in `Pulumi.prod.yaml` and the state with an **empty passphrase**. The real protection is Entra ID: only members of `TI Ameciclo` can read the `pulumi-state` blob container, so state secrets are exactly as exposed as the group. Keep that container's RBAC limited to the group. Application secrets live in Coolify per-app env vars
- HTTPS is automatic for any domain configured on a Coolify resource

## Access

Members of the **TI Ameciclo** Entra ID group can access the VM and database using their own Azure AD identity — no shared SSH key or DB password needed, and access can be revoked per-person by removing them from the group.

See **[docs/connecting.md](docs/connecting.md)** for tested, step-by-step commands (SSH, tunneling to the private-only Postgres server, and the non-obvious AAD username quirk for group-based DB admin).

## CI

PRs touching `infrastructure/pulumi/**` automatically run `pulumi preview` ([`.github/workflows/pulumi-preview.yml`](.github/workflows/pulumi-preview.yml)) and comment the diff. It authenticates to Azure via OIDC (no stored client secret) — a federated Entra ID app scoped to this repo's PRs, with `Reader` on the resource group and `Storage Blob Data Contributor` on the `pulumi-state` container only. Runs only for PRs from within the org: GitHub withholds the OIDC token and secrets from fork-originated PRs by default, so this fails closed rather than exposing Azure access to outside contributors.

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
