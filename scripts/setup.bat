@echo off
setlocal

REM Define connection info
set SYS_CONN=sys@localhost:1521/xe as sysdba
set DEV_USER=SHOP_DEV
set PDB_NAME=ONLINE_SHOP_PDB
set DEV_CONN=%DEV_USER%@localhost:1521/%PDB_NAME%

echo Starting DB setup...

REM SYSDBA actions
echo Connecting as SYSDBA...
(
echo @..\dba\create_pdb.sql
echo @..\dba\roles_users.sql
echo @..\dba\directories.sql
echo @..\dba\grants.sql
echo EXIT
) | sqlplus %SYS_CONN%

REM DEV user actions
echo Connecting as %DEV_USER%...
(
echo @..\schema\ddl\tables\lookup_tables.sql
echo @..\schema\dml\lookup_data.sql
echo @..\schema\ddl\tables\core_tables.sql
echo @..\schema\ddl\tables\backup_tables.sql
echo @..\schema\ddl\tables\error_table.sql
echo @..\schema\ddl\sequences\sequences.sql
echo @..\schema\ddl\views\views.sql
echo @..\schema\plsql\triggers\triggers.sql
echo @..\schema\plsql\triggers\shipment_checks.sql
echo @..\schema\plsql\triggers\backup_triggers.sql
echo @..\schema\plsql\procedures\record_error.sql
echo @..\schema\plsql\procedures\generate_users.sql
echo @..\schema\plsql\procedures\generate_products.sql
echo @..\schema\plsql\procedures\generate_shipments.sql
echo @..\schema\plsql\procedures\generate_order_items.sql
echo @..\schema\plsql\procedures\generate_orders.sql
echo @..\schema\plsql\procedures\generate_cities.sql
echo @..\schema\plsql\procedures\generate_addresses.sql
echo @..\schema\ddl\views\views.sql
echo @..\schema\ddl\public_synonyms\public_synonyms.sql
echo @..\schema\ddl\indexes\indexes.sql
echo @..\schema\plsql\procedures\seed.sql
echo EXIT
) | sqlplus -s %DEV_CONN%

echo Script executed successfully!

endlocal
