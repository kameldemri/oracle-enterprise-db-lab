@echo off
setlocal

REM Run the SQL script located next to this batch file
sqlplus / as sysdba @"%~dp0clone_pdb.sql"
