#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Bash equivalent of scripts/clone/clone_pdb.bat
sqlplus / as sysdba @"${SCRIPT_DIR}/clone_pdb.sql"
