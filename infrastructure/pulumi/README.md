# Pulumi stack

Azure infrastructure for Ameciclo — VNet, VM (Coolify), Postgres Flexible Server, Blob Storage. TypeScript, self-managed state/secrets (no Pulumi Cloud).

See the [root README](../../README.md) for setup, deployment, configuration, cost, and security. See [docs/connecting.md](../../docs/connecting.md) for SSH/DB access.

```bash
npm install
pulumi preview
pulumi up
```

- `index.ts` — network, Postgres, storage resources
- `vm.ts` — the Coolify VM, including its cloud-init and AAD SSH extension
- `scripts/setup.sh` — one-time local environment setup
