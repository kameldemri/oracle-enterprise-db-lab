#!/usr/bin/env bash
set -euo pipefail

# Bash equivalent of scripts/cold_ops/cold_backup.bat.
#
# Notes:
# - This is intended for *host* Oracle installations where you can access datafiles.
# - If you're running Oracle XE in Docker, "cold backup by copying datafiles" should be done
#   inside the container or via volume paths (out of scope for this lightweight repo).

ORACLE_SID="${ORACLE_SID:-XE}"
SYS_CONN="${SYS_CONN:-/ as sysdba}"

# Base folder for cold backups. Override to whatever makes sense on Linux.
BASE_COLD_BACKUP_DIR="${BASE_COLD_BACKUP_DIR:-/var/backups/oracle/cold}"

# Oracle home/base layout varies on Linux; keep this configurable.
ORACLE_BASE="${ORACLE_BASE:-/opt/oracle}"
DATA_DIR="${DATA_DIR:-${ORACLE_BASE}/oradata/${ORACLE_SID}}"
CONFIG_DIR="${CONFIG_DIR:-${ORACLE_BASE}/database}"

DATE_TAG="$(date +%F_%H-%M-%S)"
BACKUP_DIR="${BASE_COLD_BACKUP_DIR}/${DATE_TAG}"

mkdir -p \
  "${BACKUP_DIR}/datafiles" \
  "${BACKUP_DIR}/controlfiles" \
  "${BACKUP_DIR}/logfiles" \
  "${BACKUP_DIR}/oracle_database_folder/database"

echo "Shutting down database..."
sqlplus -s "${SYS_CONN}" <<SQL
SHUTDOWN IMMEDIATE;
EXIT;
SQL

echo "Copying datafiles (.dbf/.DBF)..."
shopt -s nullglob
cp -f "${DATA_DIR}"/*.{dbf,DBF} "${BACKUP_DIR}/datafiles/" 2>/dev/null || true

echo "Copying controlfiles (.ctl/.CTL)..."
cp -f "${DATA_DIR}"/*.{ctl,CTL} "${BACKUP_DIR}/controlfiles/" 2>/dev/null || true

echo "Copying redologs (.log/.LOG)..."
cp -f "${DATA_DIR}"/*.{log,LOG} "${BACKUP_DIR}/logfiles/" 2>/dev/null || true
shopt -u nullglob

echo "Copying Oracle config folder..."
cp -a "${CONFIG_DIR}/." "${BACKUP_DIR}/oracle_database_folder/database/"

echo "Starting database..."
sqlplus -s "${SYS_CONN}" <<SQL
STARTUP;
EXIT;
SQL

echo "[SUCCESS] Cold backup complete at: ${BACKUP_DIR}"
