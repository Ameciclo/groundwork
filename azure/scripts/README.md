# Azure Database Scripts

This directory contains scripts for managing Azure PostgreSQL databases and users.

## Setup Database Users

The `setup-database-users.sh` script creates dedicated database users for each application with appropriate permissions.

### What it does:

1. Creates three database users:
   - `strapi_user` for the Strapi CMS
   - `atlas_user` for the Atlas documentation
   - `zitadel_user` for the Zitadel identity platform

2. Generates secure random passwords for each user

3. Grants appropriate permissions:
   - Full access to their respective databases
   - Permissions on all tables and sequences
   - Default privileges for future objects

### Prerequisites:

- PostgreSQL client (`psql`) installed
- Access to the Azure PostgreSQL server (via VM or VPN)
- Admin password for the PostgreSQL server

### Usage:

From the VM (recommended):

```bash
# SSH into the VM
ssh azureuser@<vm-ip>

# Run the script with admin password
POSTGRES_ADMIN_PASSWORD='your-admin-password' ./setup-database-users.sh
```

Or from your local machine (if you have network access):

```bash
cd azure/scripts
POSTGRES_ADMIN_PASSWORD='your-admin-password' ./setup-database-users.sh
```

### Output:

The script will output the generated credentials for each application. **Save these securely!**

Example output:
```
Strapi Database Credentials:
  Host: ameciclo-postgres.postgres.database.azure.com
  Database: strapi
  User: strapi_user
  Password: <generated-password>

Atlas Database Credentials:
  Host: ameciclo-postgres.postgres.database.azure.com
  Database: atlas
  User: atlas_user
  Password: <generated-password>

Zitadel Database Credentials:
  Host: ameciclo-postgres.postgres.database.azure.com
  Database: zitadel
  User: zitadel_user
  Password: <generated-password>
```

### Next Steps:

After running the script:

1. **Store passwords securely** in a password manager or secrets vault

2. **Update Kubernetes secrets** with the new credentials:
   ```bash
   # For Strapi
   kubectl create secret generic strapi-db-credentials \
     --from-literal=username=strapi_user \
     --from-literal=password=<strapi-password> \
     -n strapi

   # For Atlas
   kubectl create secret generic atlas-db-credentials \
     --from-literal=username=atlas_user \
     --from-literal=password=<atlas-password> \
     -n atlas

   # For Zitadel
   kubectl create secret generic zitadel-db-credentials \
     --from-literal=username=zitadel_user \
     --from-literal=password=<zitadel-password> \
     -n zitadel
   ```

3. **Update application configurations** to use the dedicated users instead of the admin user

4. **Test the connections** to ensure each application can connect with its dedicated user

### Security Benefits:

✅ **Isolation**: Each application can only access its own database
✅ **Least Privilege**: Users have only the permissions they need
✅ **Audit Trail**: Easier to track which application made which changes
✅ **Safety**: Accidental operations in one app won't affect others
✅ **Compliance**: Follows security best practices

### Re-running the Script:

The script is idempotent - you can run it multiple times safely. If users already exist, it will update their passwords with new random values.

**Warning**: Re-running will generate NEW passwords, so you'll need to update all secrets and configurations again.

