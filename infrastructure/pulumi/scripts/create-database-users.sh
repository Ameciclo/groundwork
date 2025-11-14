#!/bin/bash
set -e

# Create PostgreSQL Database Users
# This script must be run from the K3s VM which has VNet access to the private PostgreSQL server
#
# Usage:
#   ssh azureuser@<k3s-vm-ip>
#   # Copy this script to the VM
#   chmod +x create-database-users.sh
#   POSTGRES_ADMIN_PASSWORD='<password>' ./create-database-users.sh

echo "=========================================="
echo "PostgreSQL Database Users Setup"
echo "=========================================="
echo ""

# Check if required environment variables are set
if [ -z "$POSTGRES_ADMIN_PASSWORD" ]; then
    echo "Error: POSTGRES_ADMIN_PASSWORD environment variable is not set"
    echo "Usage: POSTGRES_ADMIN_PASSWORD='your-password' ./create-database-users.sh"
    exit 1
fi

# PostgreSQL connection details
PG_HOST="ameciclo-postgres.postgres.database.azure.com"
PG_ADMIN_USER="psqladmin"

# Generate secure random passwords for each user
STRAPI_PASSWORD=$(openssl rand -base64 32)
ATLAS_PASSWORD=$(openssl rand -base64 32)
ZITADEL_PASSWORD=$(openssl rand -base64 32)

echo "Step 1: Creating database users..."
echo ""

# Create Strapi user
echo "Creating strapi_user..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "CREATE USER strapi_user WITH PASSWORD '$STRAPI_PASSWORD';" 2>/dev/null || echo "  User already exists, updating password..."

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "ALTER USER strapi_user WITH PASSWORD '$STRAPI_PASSWORD';"

# Create Atlas user
echo "Creating atlas_user..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "CREATE USER atlas_user WITH PASSWORD '$ATLAS_PASSWORD';" 2>/dev/null || echo "  User already exists, updating password..."

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "ALTER USER atlas_user WITH PASSWORD '$ATLAS_PASSWORD';"

# Create Zitadel user
echo "Creating zitadel_user..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "CREATE USER zitadel_user WITH PASSWORD '$ZITADEL_PASSWORD';" 2>/dev/null || echo "  User already exists, updating password..."

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d postgres \
  -c "ALTER USER zitadel_user WITH PASSWORD '$ZITADEL_PASSWORD';"

echo ""
echo "Step 2: Granting database permissions..."
echo ""

# Grant permissions for Strapi
echo "Granting permissions to strapi_user on strapi database..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d strapi \
  -c "GRANT ALL PRIVILEGES ON DATABASE strapi TO strapi_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d strapi \
  -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO strapi_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d strapi \
  -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO strapi_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d strapi \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO strapi_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d strapi \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO strapi_user;"

# Grant permissions for Atlas
echo "Granting permissions to atlas_user on atlas database..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d atlas \
  -c "GRANT ALL PRIVILEGES ON DATABASE atlas TO atlas_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d atlas \
  -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO atlas_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d atlas \
  -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO atlas_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d atlas \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO atlas_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d atlas \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO atlas_user;"



# Grant permissions for Zitadel
echo "Granting permissions to zitadel_user on zitadel database..."
PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d zitadel \
  -c "GRANT ALL PRIVILEGES ON DATABASE zitadel TO zitadel_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d zitadel \
  -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO zitadel_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d zitadel \
  -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO zitadel_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d zitadel \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO zitadel_user;"

PGSSLMODE=require PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" psql \
  -h "$PG_HOST" \
  -U "$PG_ADMIN_USER" \
  -d zitadel \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO zitadel_user;"

echo ""
echo "=========================================="
echo "✅ Database users created successfully!"
echo "=========================================="
echo ""
echo "IMPORTANT: Save these credentials securely!"
echo ""
echo "Strapi Database Credentials:"
echo "  Host: $PG_HOST"
echo "  Database: strapi"
echo "  User: strapi_user"
echo "  Password: $STRAPI_PASSWORD"
echo ""
echo "Atlas Database Credentials:"
echo "  Host: $PG_HOST"
echo "  Database: atlas"
echo "  User: atlas_user"
echo "  Password: $ATLAS_PASSWORD"
echo ""
echo "Zitadel Database Credentials:"
echo "  Host: $PG_HOST"
echo "  Database: zitadel"
echo "  User: zitadel_user"
echo "  Password: $ZITADEL_PASSWORD"
echo ""
