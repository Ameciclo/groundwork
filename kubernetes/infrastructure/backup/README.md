# PostgreSQL Backup para Azure Blob Storage

Este diretório contém a configuração de backup automático do PostgreSQL para Azure Blob Storage.

## 🎯 Objetivo

Criar backups exportáveis do Azure PostgreSQL para garantir portabilidade dos dados em caso de:
- Fim do Azure Grant
- Migração para outro provedor (Hetzner, etc)
- Disaster recovery

> **Nota:** O backup automático do Azure PostgreSQL NÃO permite exportar os dados.
> Este CronJob cria backups via `pg_dump` que podem ser baixados e usados em qualquer lugar.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                           VNet Azure                                │
│                                                                     │
│   ┌───────────────────────────────────────┐                        │
│   │              K3s Cluster               │                        │
│   │                                        │                        │
│   │  ┌────────────────────────────────┐   │   ┌────────────────┐   │
│   │  │  CronJob: postgres-backup      │   │   │  PostgreSQL    │   │
│   │  │  Schedule: 0 3 * * * (3am UTC) │───────│  (private)     │   │
│   │  │                                │   │   │                │   │
│   │  │  Image: azure-cli + pg_dump   │   │   │  - atlas       │   │
│   │  └───────────────┬────────────────┘   │   │  - strapi      │   │
│   │                  │                    │   │  - zitadel     │   │
│   └──────────────────┼────────────────────┘   └────────────────┘   │
│                      │                                              │
│                      │ az storage blob upload                       │
│                      ▼                                              │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │              Azure Blob Storage (backups container)          │  │
│   │                                                              │  │
│   │   ameciclostor.../backups/postgres/                         │  │
│   │   ├── 20241127_030000/                                      │  │
│   │   │   ├── atlas_20241127_030000.dump                        │  │
│   │   │   ├── strapi_20241127_030000.dump                       │  │
│   │   │   └── zitadel_20241127_030000.dump                      │  │
│   │   ├── 20241128_030000/                                      │  │
│   │   └── ...                                                   │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 📋 Configuração

### 1. Obter credenciais

```bash
cd infrastructure/pulumi

# Storage Account name
pulumi stack output storageAccountName

# PostgreSQL password
pulumi stack output postgresqlAdminPassword --show-secrets

# Storage Account key (via Azure CLI)
az storage account keys list \
  --account-name $(pulumi stack output storageAccountName) \
  --query '[0].value' -o tsv
```

### 2. Criar projeto no Infisical

Criar projeto `backup` no Infisical com as seguintes secrets:

| Secret | Valor | Como obter |
|--------|-------|------------|
| `PGHOST` | `ameciclo-postgres.privatelink.postgres.database.azure.com` | Fixo |
| `PGUSER` | `psqladmin` | Fixo |
| `PGPASSWORD` | `***` | `pulumi stack output postgresqlAdminPassword --show-secrets` |
| `AZURE_STORAGE_ACCOUNT` | `ameciclostor...` | `pulumi stack output storageAccountName` |
| `AZURE_STORAGE_KEY` | `***` | `az storage account keys list ...` |
| `AZURE_CONTAINER` | `backups` | Fixo (já existe no Pulumi) |

### 3. Deploy via ArgoCD

```bash
kubectl apply -f kubernetes/argocd/infrastructure/backup.yaml
```

## 🕐 Schedule

| Frequência | Horário | Retenção |
|------------|---------|----------|
| Diário | 03:00 UTC (00:00 BRT) | 30 dias |

## 🔧 Comandos Úteis

### Executar backup manual

```bash
kubectl create job --from=cronjob/postgres-backup manual-backup-$(date +%s) -n backup
```

### Ver logs do backup

```bash
# Logs do último job
kubectl logs -n backup -l app.kubernetes.io/name=postgres-backup --tail=100

# Seguir logs em tempo real
kubectl logs -n backup -l app.kubernetes.io/name=postgres-backup -f
```

### Ver status dos jobs

```bash
kubectl get jobs -n backup
kubectl get cronjob -n backup
```

### Listar backups no Azure Blob

```bash
# Via Azure CLI
az storage blob list \
  --account-name <storage-account> \
  --container-name backups \
  --prefix "postgres/" \
  --query "[].{name:name, size:properties.contentLength}" \
  --output table
```

## 🔄 Restore

### Baixar backup do Azure

```bash
# Criar diretório local
mkdir -p ./restore

# Baixar todos os dumps de uma data específica
az storage blob download-batch \
  --account-name <storage-account> \
  --source backups \
  --pattern "postgres/20241127_030000/*" \
  --destination ./restore
```

### Restaurar em novo servidor PostgreSQL

```bash
# Criar databases (se não existirem)
createdb -h NEW_HOST -U postgres atlas
createdb -h NEW_HOST -U postgres strapi
createdb -h NEW_HOST -U postgres zitadel

# Restaurar cada database
pg_restore -h NEW_HOST -U postgres -d atlas -v ./restore/atlas_20241127_030000.dump
pg_restore -h NEW_HOST -U postgres -d strapi -v ./restore/strapi_20241127_030000.dump
pg_restore -h NEW_HOST -U postgres -d zitadel -v ./restore/zitadel_20241127_030000.dump
```

## 📊 Monitoramento

### Verificar jobs

```bash
# Jobs recentes
kubectl get jobs -n backup --sort-by=.metadata.creationTimestamp

# CronJob status
kubectl describe cronjob postgres-backup -n backup
```

### Alertas recomendados

Configurar no Grafana/Prometheus para alertar se:
- Job falhou nas últimas 24h
- Nenhum backup novo nos últimos 2 dias

## 💰 Custo

| Item | Custo |
|------|-------|
| Azure Blob Storage | Já incluído no Grant |
| Estimativa por backup | ~10-50MB por database |
| 30 dias de retenção | ~1-5GB total |

## 🔗 Relacionado

- [Plano de Contingência](../../../docs/CONTINGENCY_PLAN.md)
- [Infisical Config](../infisical/README.md)
- [Pulumi Infrastructure](../../../infrastructure/pulumi/)

