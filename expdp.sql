-- full cdb
expdp system@XE full=Y directory=full_cdb_exp_dir dumpfile=full_cdb.dmp logfile=full_cdb_export.log filesize=500M reuse_dumpfiles=yes

-- full pdb
expdp system@online_shop_pdb directory=full_pdb_exp_dir dumpfile=shop_full.dmp logfile=shop_full.log full=y

-- user schema
expdp super_admin@ONLINE_SHOP_PDB DIRECTORY=schema_exp_dir DUMPFILE=shop_schema.dmp LOGFILE=shop_schema.log SCHEMAS=shop_dev
-- must use system to import it
-- also works with another user (huh any diff?) 
expdp shop_dev/kamel@ONLINE_SHOP_PDB DIRECTORY=dp_backups DUMPFILE=shop_schema.dmp LOGFILE=shop_schema.log SCHEMAS=shop_dev

-- does the tables need public synonyms
expdp shop_dev@ONLINE_SHOP_PDB DIRECTORY=table_exp_dir DUMPFILE=orders_table.dmp LOGFILE=orders_table.log TABLES=orders,order_items

-- export tablespace (what is the purpose?)
expdp super_admin@ONLINE_SHOP_PDB DIRECTORY=ts_exp_dir DUMPFILE=app_ts.dmp LOGFILE=app_ts.log TABLESPACES=online_shop_ts


-- OPTIONS: CONTENT=MATADATA_ONLY, CONTENT=DATA_ONLY, QUERY=...
