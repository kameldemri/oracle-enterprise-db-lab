@echo off
REM === CONFIGURATION ===
set ORACLE_SID=XE
set SYS_CONN=/ as sysdba
set BASE_COLD_BACKUP_DIR=Z:\cold
set ORACLE_BASE=C:\app\Administrator\product\21c
set DATA_DIR=%ORACLE_BASE%\oradata\%ORACLE_SID%
set CONFIG_DIR=%ORACLE_BASE%\database

REM === ASK FOR TIMESTAMP TO RESTORE ===
set /p RESTORE_TAG=Enter the backup timestamp folder name (e.g., 2025-07-16_23-40-52): 
set BACKUP_DIR=%BASE_COLD_BACKUP_DIR%\%RESTORE_TAG%

REM === VALIDATION ===
if not exist "%BACKUP_DIR%" (
  echo [ERROR] Backup directory "%BACKUP_DIR%" not found!
  pause
  exit /b
)

REM === SHUTDOWN DB ===
echo Shutting down database...
(
  echo SHUTDOWN IMMEDIATE;
  echo EXIT;
) | sqlplus -s "%SYS_CONN%"

REM === RESTORE FILES ===
echo Restoring datafiles (.DBF)...
copy /Y "%BACKUP_DIR%\datafiles\*.DBF" "%DATA_DIR%"

echo Restoring controlfiles (.CTL)...
copy /Y "%BACKUP_DIR%\controlfiles\*.CTL" "%DATA_DIR%"

echo Restoring redologs (.LOG)...
copy /Y "%BACKUP_DIR%\logfiles\*.LOG" "%DATA_DIR%"

echo Restoring Oracle config folder...
xcopy /E /I /Y "%BACKUP_DIR%\oracle_database_folder\database" "%CONFIG_DIR%"

REM === STARTUP DB ===
echo Starting database...
(
  echo STARTUP;
  echo EXIT;
) | sqlplus -s "%SYS_CONN%"

echo [SUCCESS] Cold restore completed from: %BACKUP_DIR%
pause
