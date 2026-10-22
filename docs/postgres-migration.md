# Migrating to the public PostgreSQL server

> **Status: done.** The data was copied from the original server to `ameciclo-postgres-pub` (PostgreSQL 18), Strapi was switched over, and the original server (`ameciclo-postgres`) was removed. This page is kept as the record of how it was done and as a template for a future move. Steps 1-3 and 5 are history; step 4 (public access) is still how you open the server to the internet.

The original server (`ameciclo-postgres`) was VNet-integrated: it had no public endpoint and never could (Azure fixes the networking mode at creation). `ameciclo-postgres-pub` has a public endpoint, firewalled, plus a Private Endpoint in the VM subnet, so Coolify apps use a private IP and external clients (Cloudflare Hyperdrive) can use the public one.

## 1. Create the new server

Public access stays **closed** at this point (no firewall rules).

```bash
cd infrastructure/pulumi
pulumi preview    # expect only creates, nothing changed or deleted

# terminal 1: tunnel to the NEW server (the roles are created through it)
az ssh vm -g ameciclo-rg-prod -n ameciclo-coolify-vm -- \
  -N -L 15433:ameciclo-postgres-pub.postgres.database.azure.com:5432

# terminal 2
PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv) pulumi up
```

This creates the server, the `strapi`/`atlas`/`ameciclo` databases, the Private Endpoint, and the roles `strapi_user`, `atlas_user`, `ameciclo` with fresh passwords. If the roles fail because the tunnel couldn't connect yet (the server takes a few minutes to become reachable), re-run `pulumi up`.

Get the new passwords:

```bash
pulumi stack output strapiPubDbPassword --show-secrets
```

## 2. Copy the data

Only `strapi` has data worth moving (`ameciclo` is empty; `atlas` is not deployed).

1. Stop Strapi in Coolify so nothing writes during the copy.
2. Open both tunnels (the old one on 15432, the new one on 15433):
   ```bash
   az ssh vm -g ameciclo-rg-prod -n ameciclo-coolify-vm -- \
     -N -L 15432:ameciclo-postgres.postgres.database.azure.com:5432 \
        -L 15433:ameciclo-postgres-pub.postgres.database.azure.com:5432
   ```
3. Run the script. The old `strapi_user` password is in Strapi's `DATABASE_URL` in Coolify.
   ```bash
   SRC_URL='postgres://strapi_user:<old password>@localhost:15432/strapi?sslmode=require' \
   DST_URL='postgres://strapi_user:<new password>@localhost:15433/strapi?sslmode=require' \
   infrastructure/pulumi/scripts/migrate-db.sh
   ```
   It refuses to run if the destination isn't empty, and it compares row counts per table at the end. Only continue if it prints `OK`.

## 3. Switch the apps

In Coolify, change Strapi's `DATABASE_URL` host to `ameciclo-postgres-pub.postgres.database.azure.com` with the new `strapi_user` password, then start it and check the logs. From the VM this resolves to the Private Endpoint's private IP; verify with `getent hosts ameciclo-postgres-pub.postgres.database.azure.com` (it should show a `10.10.1.x` address).

## 4. Open public access (only if you need it)

Nothing from the internet can connect until you allow it:

```bash
# a specific IP (e.g. your office)
pulumi config set --path 'postgresAllowedIps[0]' 203.0.113.7

# Cloudflare Hyperdrive: Cloudflare's published IPv4 ranges (cloudflare-ips.ts)
pulumi config set postgresAllowCloudflare true

# everything (avoid)
# pulumi config set postgresAllowAllIps true
pulumi up
```

Hyperdrive has no smaller egress range than Cloudflare's own (https://www.cloudflare.com/ips/), so `postgresAllowCloudflare` opens those ranges. They are shared by every Cloudflare customer's Workers, so the only barriers are TLS and the role's password. Refresh the list in `cloudflare-ips.ts` if Cloudflare changes it. Create a dedicated read-only role for the Worker rather than reusing `strapi_user`:

```ts
export const hyperdriveDbPassword = createDbRole("pub-hyperdrive", "ameciclo", {
  roleName: "hyperdrive",
  readOnly: true,
  provider: postgresPubProvider,
  dependsOn: pubDatabases,
});
```

## 5. Retire the old server

Keep it for about a week as a rollback (point `DATABASE_URL` back at it). Then remove the old server and its databases, the `postgresql` provider/roles, the private DNS link, and the database subnet from `index.ts`, and make the new server the only `postgres*` in the docs. Update `docs/connecting.md` (host names, and drop the "why private" section) and the tunnel instructions in the README.
