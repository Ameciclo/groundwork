#!/bin/bash
set -euo pipefail

# Copy one PostgreSQL database from the private server to the public one.
#
# Both servers are reachable only through SSH tunnels to the VM, so open them
# first (see docs/postgres-migration.md), then:
#
#   SRC_URL='postgres://strapi_user:<old>@localhost:15432/strapi?sslmode=require' \
#   DST_URL='postgres://strapi_user:<new>@localhost:15433/strapi?sslmode=require' \
#   ./migrate-db.sh
#
# Connect as the app's own user on BOTH sides. Objects are restored owned by
# the connecting user (--no-owner), so the app owns its tables afterwards.
#
# Stop the app that writes to the source database BEFORE running this, or the
# copy will miss writes made during the dump.
#
# The destination must be empty: the script refuses to restore into a
# database that already has tables.

: "${SRC_URL:?set SRC_URL (source database URL)}"
: "${DST_URL:?set DST_URL (destination database URL)}"

for cmd in psql pg_dump pg_restore; do
    command -v "$cmd" > /dev/null || { echo "Error: $cmd not found"; exit 1; }
done

WORKDIR=$(mktemp -d)
chmod 700 "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT
DUMP="$WORKDIR/db.dump"

table_counts() {
    # Exact row count per user table, sorted, one "schema.table count" per line
    local url="$1" tables
    tables=$(psql "$url" -At -c "
        select format('%I.%I', table_schema, table_name)
        from information_schema.tables
        where table_type = 'BASE TABLE'
          and table_schema not in ('pg_catalog', 'information_schema')
        order by 1")
    [ -z "$tables" ] && return 0
    while IFS= read -r t; do
        printf '%s %s\n' "$t" "$(psql "$url" -At -c "select count(*) from $t")"
    done <<< "$tables"
}

echo "== Checking connections"
psql "$SRC_URL" -At -c "select 'source: ' || current_database() || ' as ' || current_user"
psql "$DST_URL" -At -c "select 'destination: ' || current_database() || ' as ' || current_user"

echo "== Checking the destination is empty"
DST_TABLES=$(table_counts "$DST_URL" | wc -l)
if [ "$DST_TABLES" -ne 0 ]; then
    echo "Error: destination already has $DST_TABLES table(s). Refusing to restore into it."
    exit 1
fi

echo "== Counting source rows"
table_counts "$SRC_URL" > "$WORKDIR/src.counts"
echo "   $(wc -l < "$WORKDIR/src.counts") tables"

echo "== Dumping source"
pg_dump "$SRC_URL" --format=custom --no-owner --no-privileges --file "$DUMP"
echo "   $(du -h "$DUMP" | cut -f1)"

echo "== Restoring into destination"
pg_restore --dbname "$DST_URL" --no-owner --no-privileges --exit-on-error "$DUMP"

echo "== Comparing row counts"
table_counts "$DST_URL" > "$WORKDIR/dst.counts"
if diff "$WORKDIR/src.counts" "$WORKDIR/dst.counts"; then
    echo "OK: all $(wc -l < "$WORKDIR/src.counts") tables match."
else
    echo "MISMATCH: row counts differ (diff above). Do NOT switch the app over."
    exit 1
fi
