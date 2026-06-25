#!/usr/bin/env bash
set -euo pipefail

# Bash equivalent of scripts/cold_ops/cold_restore.bat.

ORACLE_SID="${ORACLE_SID:-XE}"
SYS_CONN="${SYS_CONN:-/ as sysdba}"

BASE_COLD_BACKUP_DIR="${BASE_COLD_BACKUP_DIR:-/var/backups/oracle/cold}"

ORACLE_BASE="${ORACLE_BASE:-/opt/oracle}"
DATA_DIR="${DATA_DIR:-${ORACLE_BASE}/oradata/${ORACLE_SID}}"
CONFIG_DIR="${CONFIG_DIR:-${ORACLE_BASE}/database}"

read -r -p "Enter the backup timestamp folder name (e.g., 2025-07-16_23-40-52): " RESTORE_TAG
BACKUP_DIR="${BASE_COLD_BACKUP_DIR}/${RESTORE_TAG}"

if [[ ! -d "${BACKUP_DIR}" ]]; then
  echo "[ERROR] Backup directory '${BACKUP_DIR}' not found!"
  exit 1
fi

echo "Shutting down database..."
sqlplus -s "${SYS_CONN}" <<SQL
SHUTDOWN IMMEDIATE;
EXIT;
SQL

echo "Restoring datafiles (.dbf/.DBF)..."
shopt -s nullglob
cp -f "${BACKUP_DIR}/datafiles/"* "${DATA_DIR}/" 2>/dev/null || true

echo "Restoring controlfiles (.ctl/.CTL)..."
cp -f "${BACKUP_DIR}/controlfiles/"* "${DATA_DIR}/" 2>/dev/null || true

echo "Restoring redologs (.log/.LOG)..."
cp -f "${BACKUP_DIR}/logfiles/"* "${DATA_DIR}/" 2>/dev/null || true
shopt -u nullglob

echo "Restoring Oracle config folder..."
cp -a "${BACKUP_DIR}/oracle_database_folder/database/." "${CONFIG_DIR}/"

echo "Starting database..."
sqlplus -s "${SYS_CONN}" <<SQL
STARTUP;
EXIT;
SQL

echo "[SUCCESS] Cold restore completed from: ${BACKUP_DIR}"
