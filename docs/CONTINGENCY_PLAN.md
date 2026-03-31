# 🚨 Plano de Contingência: Migração Azure → Hetzner

> **Objetivo:** Documentar o plano de ação caso o Azure for Nonprofits Grant expire ou seja descontinuado.

## 📊 Inventário Atual (Azure)

### Infraestrutura

| Recurso             | Specs                                       | Custo Estimado/mês |
| ------------------- | ------------------------------------------- | ------------------ |
| **VM K3s**          | Standard_B4as_v2 (4 vCPU, 16GB RAM)         | ~$109              |
| **PostgreSQL**      | Flexible Server B2s (2 vCPU, 4GB RAM, 32GB) | ~$25               |
| **Storage Account** | Standard LRS (media, backups, logs)         | ~$5                |
| **VNet + DNS + IP** | Networking                                  | ~$10               |
| **TOTAL**           |                                             | **~$150/mês**      |

### Bancos de Dados PostgreSQL

| Database  | Aplicação                                           |
| --------- | --------------------------------------------------- |
| `atlas`   | APIs de dados (traffic-deaths, cyclist-counts, etc) |
| `strapi`  | CMS Strapi                                          |
| `zitadel` | Identity Provider (SSO)                             |

### Aplicações no K3s

| App                     | Namespace | Descrição                    |
| ----------------------- | --------- | ---------------------------- |
| **Strapi**              | `strapi`  | CMS headless                 |
| **Atlas Docs**          | `atlas`   | Documentação das APIs        |
| **Traffic Deaths API**  | `atlas`   | API de mortes no trânsito    |
| **Cyclist Counts API**  | `atlas`   | API de contagem de ciclistas |
| **Cyclist Profile API** | `atlas`   | API de perfil do ciclista    |

### Infraestrutura K8s

| Componente             | Função                                     |
| ---------------------- | ------------------------------------------ |
| **Traefik**            | Ingress Controller + HTTPS (Let's Encrypt) |
| **ArgoCD**             | GitOps deployment                          |
| **Tailscale**          | VPN + Subnet Router                        |
| **Infisical**          | Secret management                          |
| **Prometheus/Grafana** | Monitoring                                 |
| **Uptime Kuma**        | Uptime monitoring                          |

### Serviços Externos (não mudam)

| Serviço                 | Uso                       |
| ----------------------- | ------------------------- |
| **Infisical Cloud**     | Secrets management        |
| **Pulumi Cloud**        | IaC state                 |
| **GitHub**              | Code + Container Registry |
| **DigitalOcean Spaces** | Strapi media storage      |
| **Cloudflare**          | DNS                       |

---

## 🎯 Plano de Migração

### Fase 0: Preparação (Fazer AGORA enquanto tem Azure)

- [ ] **Configurar backup automático do PostgreSQL para S3 externo**
- [ ] **Documentar todas as variáveis de ambiente de cada app**
- [ ] **Testar restore de backup do PostgreSQL**
- [ ] **Exportar configurações do Zitadel**

### Fase 1: Provisionar Hetzner (Dia 1)

#### 1.1 Criar VPS no Hetzner

```bash
# Opção recomendada: CCX23 (Dedicated vCPU)
# 4 vCPU, 16GB RAM, 160GB NVMe
# Custo: €17.49/mês (~$19)

# Alternativa mais barata: CX42 (Shared vCPU)
# 8 vCPU, 16GB RAM, 160GB NVMe
# Custo: €16.40/mês (~$18)
```

#### 1.2 Criar Object Storage (S3-compatible)

```bash
# Hetzner Object Storage
# Custo: €0.0052/GB (~$5/mês para 1TB)
# Usar para: backups, logs
```

### Fase 2: Instalar PostgreSQL (Dia 1)

```bash
# No VPS Hetzner
sudo apt update && sudo apt install -y postgresql-16 postgresql-client-16

# Configurar para aceitar conexões do K3s
sudo nano /etc/postgresql/16/main/pg_hba.conf
# Adicionar: host all all 10.42.0.0/16 scram-sha-256

sudo nano /etc/postgresql/16/main/postgresql.conf
# listen_addresses = 'localhost,10.10.1.1'  # IP interno

sudo systemctl restart postgresql
```

### Fase 3: Restaurar Dados (Dia 1-2)

```bash
# Baixar backup do Azure/S3
aws s3 cp s3://ameciclo-backups/postgres/latest.sql.gz .

# Restaurar
gunzip -c latest.sql.gz | psql -U postgres

# Criar databases se necessário
createdb -U postgres atlas
createdb -U postgres strapi
createdb -U postgres zitadel
```

### Fase 4: Instalar K3s (Dia 2)

```bash
# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Copiar kubeconfig
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

### Fase 5: Bootstrap (Dia 2)

```bash
# Usar Ansible existente (adaptar inventory)
cd automation/ansible
ansible-playbook -i inventory/hetzner.yml playbooks/bootstrap.yml
```

### Fase 6: Atualizar Secrets (Dia 2)

```bash
# Atualizar DATABASE_URL no Infisical para cada app
# Formato: postgresql://user:pass@localhost:5432/dbname

# Atlas
DATABASE_URL=postgresql://postgres:SENHA@localhost:5432/atlas

# Strapi
DATABASE_URL=postgresql://postgres:SENHA@localhost:5432/strapi

# Zitadel
DATABASE_URL=postgresql://postgres:SENHA@localhost:5432/zitadel
```

### Fase 7: Deploy via ArgoCD (Dia 2-3)

```bash
# ArgoCD vai sincronizar automaticamente do Git
# Verificar status
kubectl get applications -n argocd

# Forçar sync se necessário
argocd app sync strapi
argocd app sync atlas-traffic-deaths
# etc...
```

### Fase 8: Atualizar DNS (Dia 3)

```bash
# No Cloudflare, atualizar registros A:
# *.az.ameciclo.org → IP_HETZNER (ou mudar para *.htz.ameciclo.org)
```

### Fase 9: Configurar Backups (Dia 3)

```bash
#!/bin/bash
# /usr/local/bin/pg-backup.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
S3_BUCKET="s3://ameciclo-backups/postgres"

# Dump all databases
pg_dumpall -U postgres | gzip > /tmp/backup_$TIMESTAMP.sql.gz

# Upload to Hetzner Object Storage
aws s3 cp /tmp/backup_$TIMESTAMP.sql.gz $S3_BUCKET/ \
  --endpoint-url https://fsn1.your-objectstorage.com

# Cleanup local
rm /tmp/backup_$TIMESTAMP.sql.gz

# Cleanup old backups (keep 7 days)
aws s3 ls $S3_BUCKET/ --endpoint-url https://fsn1.your-objectstorage.com | \
  while read -r line; do
    createDate=$(echo $line | awk '{print $1" "$2}')
    createDate=$(date -d "$createDate" +%s)
    olderThan=$(date -d "7 days ago" +%s)
    if [[ $createDate -lt $olderThan ]]; then
      fileName=$(echo $line | awk '{print $4}')
      aws s3 rm $S3_BUCKET/$fileName --endpoint-url https://fsn1.your-objectstorage.com
    fi
  done
```

```bash
# Cron - backup diário às 3am
echo "0 3 * * * root /usr/local/bin/pg-backup.sh" | sudo tee /etc/cron.d/pg-backup
```

---

## 💰 Comparação de Custos

| Item         | Azure (atual)     | Hetzner                  |
| ------------ | ----------------- | ------------------------ |
| VM/VPS       | $109/mês          | €17/mês (~$19)           |
| PostgreSQL   | $25/mês (managed) | $0 (self-hosted)         |
| Storage      | $5/mês            | €5/mês (~$5)             |
| Networking   | $10/mês           | $0 (incluído)            |
| **TOTAL**    | **~$150/mês**     | **~$24/mês**             |
| **Economia** | -                 | **$126/mês ($1512/ano)** |

---

## ⚠️ Trade-offs da Migração

### O que você PERDE:

| Feature                | Azure                           | Hetzner                    |
| ---------------------- | ------------------------------- | -------------------------- |
| **Managed PostgreSQL** | ✅ Backups automáticos, patches | ❌ Manual                  |
| **HA/Failover**        | ✅ Disponível                   | ❌ Single point of failure |
| **Suporte Enterprise** | ✅                              | ❌ Básico                  |
| **SLA**                | ✅ 99.9%                        | ⚠️ 99.9% (menos confiável) |
| **Compliance**         | ✅ SOC2, HIPAA                  | ⚠️ ISO 27001               |

### O que você GANHA:

| Feature          | Azure              | Hetzner           |
| ---------------- | ------------------ | ----------------- |
| **Custo**        | ❌ $150/mês        | ✅ ~$24/mês       |
| **Simplicidade** | ⚠️ Muitos serviços | ✅ Tudo em um VPS |
| **Performance**  | ⚠️ Burstable       | ✅ Dedicated vCPU |
| **Latência EU**  | ❌ West US 3       | ✅ Alemanha       |

---

## 🔧 Mudanças Necessárias no Código

### 1. Criar Pulumi para Hetzner (opcional)

```typescript
// infrastructure/pulumi-hetzner/index.ts
import * as hcloud from "@pulumi/hcloud";

const server = new hcloud.Server("k3s", {
  serverType: "ccx23",
  image: "ubuntu-22.04",
  location: "fsn1",
  sshKeys: ["sua-chave"],
});
```

### 2. Atualizar Ansible Inventory

```yaml
# automation/ansible/inventory/hetzner.yml
all:
  hosts:
    k3s:
      ansible_host: IP_HETZNER
      ansible_user: root
```

### 3. Atualizar connection strings

As apps já usam Infisical, então só precisa atualizar lá.

---

## 📋 Checklist de Migração

### Antes de Começar

- [ ] Backup completo do PostgreSQL exportado
- [ ] Teste de restore do backup funcionando
- [ ] Todas as env vars documentadas
- [ ] DNS TTL reduzido para 5 minutos

### Durante a Migração

- [ ] VPS Hetzner criado e acessível
- [ ] PostgreSQL instalado e configurado
- [ ] Dados restaurados e verificados
- [ ] K3s instalado
- [ ] ArgoCD funcionando
- [ ] Apps sincronizadas
- [ ] HTTPS funcionando (Let's Encrypt)
- [ ] Tailscale conectado

### Após a Migração

- [ ] DNS atualizado
- [ ] Backups automáticos configurados
- [ ] Monitoramento funcionando
- [ ] Uptime Kuma verificando endpoints
- [ ] Documentação atualizada

---

## 🚀 Ações Imediatas (Fazer AGORA)

### 1. Configurar Backup Externo ✅

**Status:** Configuração criada em `kubernetes/infrastructure/backup/`

O backup roda como **CronJob no K3s** (que está dentro da VNet e consegue acessar o PostgreSQL privado):

```
kubernetes/infrastructure/backup/
├── namespace.yaml          # Namespace 'backup'
├── cronjob.yaml           # CronJob que roda pg_dump diariamente
├── infisical-secret.yaml  # Secrets do Infisical
├── kustomization.yaml     # Kustomize config
└── README.md              # Documentação
```

**Para ativar:**

1. Obter credenciais:
   ```bash
   cd infrastructure/pulumi

   # Storage Account name
   pulumi stack output storageAccountName

   # PostgreSQL password
   pulumi stack output postgresqlAdminPassword --show-secrets

   # Storage Account key
   az storage account keys list \
     --account-name $(pulumi stack output storageAccountName) \
     --query '[0].value' -o tsv
   ```

2. Criar projeto `backup` no Infisical com as secrets:
   - `PGHOST`: `ameciclo-postgres.privatelink.postgres.database.azure.com`
   - `PGUSER`: `psqladmin`
   - `PGPASSWORD`: (do comando acima)
   - `AZURE_STORAGE_ACCOUNT`: (do comando acima)
   - `AZURE_STORAGE_KEY`: (do comando acima)
   - `AZURE_CONTAINER`: `backups`

3. Aplicar o ArgoCD Application:
   ```bash
   kubectl apply -f kubernetes/argocd/infrastructure/backup.yaml
   ```

4. Verificar se o CronJob foi criado:
   ```bash
   kubectl get cronjob -n backup
   ```

5. Testar backup manual:
   ```bash
   kubectl create job --from=cronjob/postgres-backup manual-test -n backup
   kubectl logs -n backup -l app.kubernetes.io/name=postgres-backup -f
   ```

6. Verificar se o backup foi criado no Azure:
   ```bash
   az storage blob list \
     --account-name <storage-account> \
     --container-name backups \
     --prefix "postgres/" \
     --output table
   ```

### 2. Documentar Secrets

Criar documento com todas as variáveis de ambiente necessárias (já estão no Infisical, mas documentar a lista).

### 3. Testar Restore

Periodicamente, testar restore do backup em um ambiente temporário.

---

## 📞 Contatos de Emergência

| Serviço             | Contato             |
| ------------------- | ------------------- |
| **Hetzner Support** | support@hetzner.com |
| **Cloudflare**      | Dashboard           |
| **DigitalOcean**    | Dashboard           |
| **Infisical**       | Dashboard           |

---

## 📅 Timeline Estimada

| Fase                     | Duração    | Downtime                 |
| ------------------------ | ---------- | ------------------------ |
| Preparação               | 1-2 horas  | 0                        |
| Provisionar Hetzner      | 30 min     | 0                        |
| Instalar PostgreSQL      | 1 hora     | 0                        |
| Restaurar dados          | 1-2 horas  | 0                        |
| Instalar K3s + Bootstrap | 2-3 horas  | 0                        |
| Deploy apps              | 1-2 horas  | 0                        |
| Atualizar DNS            | 5 min      | **~30 min** (propagação) |
| Verificação              | 1-2 horas  | 0                        |
| **TOTAL**                | **~1 dia** | **~30 min**              |

---

_Última atualização: 2025-11_
