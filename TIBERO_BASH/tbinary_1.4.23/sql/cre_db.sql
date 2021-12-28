/* ####### Tibero DB Create Sample ######### */

create database
user sys identified by tibero
character set MSWIN949  -- UTF8, EUCKR, ASCII, MSWIN949
logfile group 0 ('redo001.redo') size 50M,
        group 1 ('redo011.redo') size 50M,
        group 2 ('redo021.redo') size 50M
maxdatafiles 1024
maxlogfiles 100
maxlogmembers 8
noarchivelog
  datafile 'system001.dtf' size 100M autoextend on next 16M maxsize 3G
default tablespace USR 
  datafile 'usr001.dtf' size 128M autoextend on next 16M maxsize 3G
default temporary tablespace TEMP
  tempfile 'temp001.dtf' size 100M autoextend on next 16M maxsize 3G
  extent management local AUTOALLOCATE
undo tablespace UNDO
  datafile 'undo001.dtf' size 100M autoextend on next 16M maxsize 3G
  extent management local AUTOALLOCATE
-- extent management local UNIFORM SIZE 1M
;

