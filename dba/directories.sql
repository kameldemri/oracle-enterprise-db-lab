-- PDB
CREATE OR REPLACE DIRECTORY schema_exp_dir      AS 'Z:\data_pump\schemas';
CREATE OR REPLACE DIRECTORY ts_exp_dir          AS 'Z:\data_pump\tablespaces';
CREATE OR REPLACE DIRECTORY table_exp_dir       AS 'Z:\data_pump\tables';
CREATE OR REPLACE DIRECTORY full_pdb_exp_dir    AS 'Z:\data_pump\full_pdb';

-- CDB
ALTER SESSION SET CONTAINER=CDB$ROOT;

CREATE OR REPLACE DIRECTORY full_cdb_exp_dir    AS 'Z:\data_pump\full_cdb';