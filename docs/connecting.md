# Connecting to the VM and database

All commands below were tested live against the `prod` stack, not just copied from docs — including the one genuinely non-obvious step (the Postgres username), which is easy to get wrong.

## Prerequisites

- Membership in the **TI Ameciclo** Entra ID group (ask an existing admin — see [Access management](#access-management) below)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), logged in to the `ameciclo.onmicrosoft.com` tenant: `az login`
- The `ssh` CLI extension, one-time: `az extension add --name ssh`

## SSH into the VM

```bash
az ssh vm --resource-group ameciclo-rg-prod --name ameciclo-coolify-vm
```

Authenticates with your own Azure AD identity — no shared key to manage or leak. A shared SSH keypair also still works as a fallback (`ssh azureuser@$(pulumi stack output coolifyPublicIp)` from `infrastructure/pulumi/`), but prefer the AAD path above.

## Connecting to Postgres

The Postgres server has `publicNetworkAccess: Disabled` — it's reachable only from inside the VNet, **not directly from your laptop**, regardless of credentials. This is intentional (see [why we keep it private](#why-postgres-stays-private-only) below) — reaching it means tunneling through the VM first.

### Open a tunnel through the VM

```bash
az ssh vm --resource-group ameciclo-rg-prod --name ameciclo-coolify-vm -- \
  -N -L 15432:ameciclo-postgres.postgres.database.azure.com:5432 &
```

Leave that running in the background (or a separate terminal). Everything below connects to `localhost:15432`.

### Option A — your own Azure AD identity (recommended)

```bash
TOKEN=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)
PGPASSWORD="$TOKEN" psql "host=localhost port=15432 dbname=postgres sslmode=require" -U "TI Ameciclo"
```

**The username is the literal group name `TI Ameciclo`, not your own email/UPN.** This is how Azure Postgres's group-based AAD admin actually works: setting a *group* as administrator creates one shared, login-capable database role named after the group, and any member's token authenticates against that role — it does **not** create a per-person role under each member's UPN. Using your own UPN as the username fails with a generic `password authentication failed` error that gives no hint this is the cause (confirmed by testing both ways against the live server). Access is still individually attributable and revocable — Postgres accepts *your* token only because *you're* in the group; removing you from `TI Ameciclo` removes your ability to get a valid token, even though the DB-side role name doesn't change.

Tokens expire in 5–60 minutes — re-run the `TOKEN=...` line if a session goes stale.

### Option B — shared admin password (break-glass fallback)

```bash
pulumi stack output postgresqlAdminPassword --show-secrets   # from infrastructure/pulumi/
PGPASSWORD="<paste>" psql "host=localhost port=15432 dbname=postgres user=psqladmin sslmode=require"
```

Static shared credential — prefer Option A. Use this only if AAD auth itself is broken.

### App database users

Strapi, Atlas, Zitadel, Passbolt, and Superset each have their own database and least-privilege user (`strapi_user`, `atlas_user`, etc.), created via `infrastructure/pulumi/scripts/create-database-users.sh`. Apps connect with these directly — unrelated to the admin access described above, and unaffected by it.

## Access management

Add or remove someone's access by adding/removing them from the `TI Ameciclo` Entra ID group — no Pulumi change needed either way:

```bash
az ad group member add    --group "TI Ameciclo" --member-id <object-id>
az ad group member remove --group "TI Ameciclo" --member-id <object-id>
```

Postgres access follows immediately (their next token simply won't carry the group claim). VM SSH access is RBAC-based and may take a couple of minutes to propagate for a brand-new member.

## Why Postgres stays private-only

`publicNetworkAccess` is deliberately `Disabled`, not something to flip on for convenience. Keeping the database off the public internet entirely — reachable only via a tunnel through an already-access-controlled VM — removes an entire class of exposure (credential-stuffing, scanners, CVEs in the Postgres network stack) regardless of how strong the auth on top of it is. The tunnel step is mildly more friction, but changing it would trade a real security boundary for typing one less command.
