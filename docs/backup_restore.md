# Oracle Backup & Restore Guide

This document covers the key strategies and scripts used to manage **cold backups**, **Data Pump exports**, and **pluggable database (PDB) cloning** for the Oracle Online Shop Database.

## 1. Data Pump Exports (`expdp`)

### Full CDB Export (must run from CDB root)

```sql
expdp system@XE full=Y directory=full_cdb_exp_dir dumpfile=full_cdb.dmp logfile=full_cdb_export.log filesize=500M reuse_dumpfiles=yes
```

### Full PDB Export

```sql
expdp system@online_shop_pdb directory=full_pdb_exp_dir dumpfile=shop_full.dmp logfile=shop_full.log full=y
```

### Schema-Level Export

```sql
expdp shop_dev@ONLINE_SHOP_PDB DIRECTORY=schema_exp_dir DUMPFILE=shop_schema.dmp LOGFILE=shop_schema.log SCHEMAS=shop_dev
```

### Table-Level Export

```sql
expdp shop_dev@ONLINE_SHOP_PDB DIRECTORY=table_exp_dir DUMPFILE=orders_table.dmp LOGFILE=orders_table.log TABLES=orders,order_items
```

### Tablespace Export

```sql
expdp super_admin@ONLINE_SHOP_PDB DIRECTORY=ts_exp_dir DUMPFILE=app_ts.dmp LOGFILE=app_ts.log TABLESPACES=online_shop_ts
```

> ℹ️ Directory objects used (pointing to `Z:\`, a mapped backup server share `\\<ip>\oracle_backups`):

```sql
CREATE OR REPLACE DIRECTORY schema_exp_dir      AS 'Z:\data_pump\schemas';
CREATE OR REPLACE DIRECTORY ts_exp_dir          AS 'Z:\data_pump\tablespaces';
CREATE OR REPLACE DIRECTORY table_exp_dir       AS 'Z:\data_pump\tables';
CREATE OR REPLACE DIRECTORY full_pdb_exp_dir    AS 'Z:\data_pump\full_pdb';
-- For CDB (run in root)
CREATE OR REPLACE DIRECTORY full_cdb_exp_dir    AS 'Z:\data_pump\full_cdb';
```

---

## 2. Cold Backup Script (`cold_backup.bat`)

Shuts down the database and copies:

* Datafiles (.DBF)
* Control files (.CTL)
* Redo logs (.LOG)
* Oracle config directory

Organized under a timestamped folder inside `Z:\cold\`.

### Highlights:

* Uses `%ORACLE_SID%` and `sqlplus / as sysdba`
* Clean separation by type (`datafiles`, `logfiles`, `controlfiles`, `config`)

---

## 3. Cold Restore Script (`cold_restore.bat`)

Prompts the user for a backup timestamp folder, shuts down the DB, then:

* Restores files to Oracle’s data and config directories
* Starts the DB again

> ❗ Includes validation for directory existence.

---

## 4. PDB Cloning Workflow

Useful to snapshot or duplicate the current pluggable database.

```sql
-- Unplug current
ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB UNPLUG INTO 'Z:\clone\ONLINE_SHOP_PDB.xml';

-- Drop old PDB (keep datafiles if needed)
DROP PLUGGABLE DATABASE ONLINE_SHOP_PDB KEEP DATAFILES;

-- Create clone with file path remapping
CREATE PLUGGABLE DATABASE ONLINE_SHOP_PDB_CLONE
  USING 'Z:\clone\ONLINE_SHOP_PDB.xml'
  FILE_NAME_CONVERT = (
    'C:\app\Administrator\product\21c\oradata\XE\ONLINE_SHOP_PDB',
    'C:\app\Administrator\product\21c\oradata\XE\ONLINE_SHOP_PDB_CLONE'
  );

ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB_CLONE OPEN;
```