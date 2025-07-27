# Scripts

This document describes the core scripts used to automate database setup, backup, cloning, and restoration for the Oracle Online Shop Database.

---

## 1. Environment Setup `setup.bat`

Main batch file for initializing a fresh database environment from scratch.

### Responsibilities:

* Creates the pluggable database and connects to it
* Creates and grants roles, users, and directory objects
* Executes schema DDL (lookup tables, core tables, sequences, views, indexes, triggers)
* Loads test data and lookup values
* Seeds the full working database via PL/SQL procedures

### Key Connections Used:

* `SYS` connection to create PDB and perform privileged DBA operations
* `SHOP_DEV` connection to build and seed the actual schema

---

## 2. Cold Backup Scripts

### `cold_backup.bat`

* Gracefully shuts down the database
* Copies all physical `.DBF`, `.CTL`, and `.LOG` files into a timestamped backup folder
* Also backs up the Oracle config directory

### `cold_restore.bat`

* Prompts the user for a timestamped folder name
* Shuts down the database and restores all cold backup files
* Restarts the database after restoration

### Backup Storage:

All cold backups are stored in `Z:\cold\<timestamp>` which maps to a network backup share.

---

## 3. PDB Cloning

Script-based cloning of the pluggable database (PDB):

```sql
ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB
  UNPLUG INTO 'Z:\clone\ONLINE_SHOP_PDB.xml';

DROP PLUGGABLE DATABASE ONLINE_SHOP_PDB KEEP DATAFILES;

CREATE PLUGGABLE DATABASE ONLINE_SHOP_PDB_CLONE
  USING 'Z:\clone\ONLINE_SHOP_PDB.xml'
  FILE_NAME_CONVERT = (
    'C:\app\Administrator\product\21c\oradata\XE\ONLINE_SHOP_PDB',
    'C:\app\Administrator\product\21c\oradata\XE\ONLINE_SHOP_PDB_CLONE'
  );

ALTER PLUGGABLE DATABASE ONLINE_SHOP_PDB_CLONE OPEN;
```

### Purpose:

* Creates a fully isolated copy of the PDB for testing, rollback, or upgrade simulation

---

## 4. Directory Objects

All Data Pump exports and backups rely on Oracle directory objects mapped to local or network paths. These are created in the DBA SQL script:

```sql
CREATE OR REPLACE DIRECTORY schema_exp_dir      AS 'Z:\data_pump\schemas';
CREATE OR REPLACE DIRECTORY ts_exp_dir          AS 'Z:\data_pump\tablespaces';
CREATE OR REPLACE DIRECTORY table_exp_dir       AS 'Z:\data_pump\tables';
CREATE OR REPLACE DIRECTORY full_pdb_exp_dir    AS 'Z:\data_pump\full_pdb';
CREATE OR REPLACE DIRECTORY full_cdb_exp_dir    AS 'Z:\data_pump\full_cdb';
```

> `Z:` is a mapped alias for the remote backup location: `\\<backup-server-ip>\oracle_backups\`

---

## Notes

* All batch scripts are Windows-native and assume default Oracle 21c installation layout.
* You must have `sqlplus` in PATH or properly referenced inside scripts.
* Execute all scripts with admin privileges for full access to DB files.