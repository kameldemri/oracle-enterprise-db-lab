#!/usr/bin/env bash
set -euo pipefail

# Bash equivalent of scripts/setup.bat (keeps the same SQL execution order).
# You can override any variable via environment variables, e.g.:
#   PDB_NAME=ONLINE_SHOP_PDB DEV_USER=SHOP_DEV ./scripts/setup.sh

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

ORACLE_HOST="${ORACLE_HOST:-localhost}"
ORACLE_PORT="${ORACLE_PORT:-1521}"
XE_SERVICE="${XE_SERVICE:-xe}"

DEV_USER="${DEV_USER:-SHOP_DEV}"
PDB_NAME="${PDB_NAME:-ONLINE_SHOP_PDB}"

# Mirrors setup.bat defaults (remote SYS connect). For local installs you may prefer:
#   SYS_CONN="/ as sysdba"
SYS_CONN="${SYS_CONN:-sys@${ORACLE_HOST}:${ORACLE_PORT}/${XE_SERVICE} as sysdba}"
DEV_CONN="${DEV_CONN:-${DEV_USER}@${ORACLE_HOST}:${ORACLE_PORT}/${PDB_NAME}}"

echo "Starting DB setup..."
echo "Repo root: ${REPO_ROOT}"
echo "SYS_CONN: ${SYS_CONN}"
echo "DEV_CONN: ${DEV_CONN}"

echo "Connecting as SYSDBA..."
sqlplus -s "${SYS_CONN}" <<SQL
@${REPO_ROOT}/dba/create_pdb.sql
@${REPO_ROOT}/dba/roles_users.sql
@${REPO_ROOT}/dba/directories.sql
@${REPO_ROOT}/dba/grants.sql
EXIT
SQL

echo "Connecting as ${DEV_USER}..."
sqlplus -s "${DEV_CONN}" <<SQL
@${REPO_ROOT}/schema/ddl/tables/lookup_tables.sql
@${REPO_ROOT}/schema/dml/lookup_data.sql
@${REPO_ROOT}/schema/ddl/tables/core_tables.sql
@${REPO_ROOT}/schema/ddl/tables/backup_tables.sql
@${REPO_ROOT}/schema/ddl/tables/error_table.sql
@${REPO_ROOT}/schema/ddl/sequences/sequences.sql
@${REPO_ROOT}/schema/ddl/views/views.sql
@${REPO_ROOT}/schema/plsql/triggers/triggers.sql
@${REPO_ROOT}/schema/plsql/triggers/shipment_checks.sql
@${REPO_ROOT}/schema/plsql/triggers/backup_triggers.sql
@${REPO_ROOT}/schema/plsql/procedures/record_error.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_users.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_products.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_shipments.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_order_items.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_orders.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_cities.sql
@${REPO_ROOT}/schema/plsql/procedures/generate_addresses.sql
@${REPO_ROOT}/schema/ddl/views/views.sql
@${REPO_ROOT}/schema/ddl/public_synonyms/public_synonyms.sql
@${REPO_ROOT}/schema/ddl/indexes/indexes.sql
@${REPO_ROOT}/schema/plsql/procedures/seed.sql
EXIT
SQL

echo "Script executed successfully!"
