# oracle-enterprise-db-lab

An Oracle Database engineering lab focused on **Oracle SQL**, **PL/SQL**, **automation**, and practical **DBA workflows**.

This repository uses an **online shop** sample domain (schemas, procedures, triggers) to demonstrate enterprise-grade patterns like auditing, soft deletes, error logging, seeding, and backup/restore operations.

## What’s inside

- **`schema/`**: DDL/DML, PL/SQL procedures & triggers, and seed logic
- **`dba/`**: PDB creation, roles/users, directories, grants
- **`scripts/`**: setup, cloning, and cold backup/restore automation (Windows `.bat` + Linux `.sh`)
- **`docs/`**: data model, PL/SQL overview, script guides, backup/restore notes

## Prerequisites

- Oracle client tools available in your PATH (at least `sqlplus`)
- A running Oracle instance (local install or optional local Docker Oracle XE runtime)

## Quick start (Windows)

Run:

```bat
scripts\setup.bat
```

## Quick start (Linux)

Make scripts executable once:

```bash
chmod +x scripts/setup.sh scripts/clone/clone_pdb.sh scripts/cold_ops/*.sh
```

Run:

```bash
./scripts/setup.sh
```

### Common Linux overrides (optional)

```bash
ORACLE_HOST=localhost ORACLE_PORT=1521 XE_SERVICE=xe PDB_NAME=ONLINE_SHOP_PDB DEV_USER=SHOP_DEV ./scripts/setup.sh
```

## Documentation

- `docs/scripts.md`
- `docs/backup_restore.md`
- `docs/plsql.md`
- `docs/data_model.md`
