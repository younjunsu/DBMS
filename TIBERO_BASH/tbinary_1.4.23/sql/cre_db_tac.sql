/* ####### TAC DB Create Sample ######### */

create database "TAC"
user sys identified by tibero
character set MSWIN949  -- UTF8, EUCKR, ASCII, MSWIN949
logfile group 0 ('redo001') size 100M,
        group 1 ('redo011') size 100M,
        group 2 ('redo021') size 100M
maxdatafiles 1024
maxlogfiles 100
maxlogmembers 8
noarchivelog
  datafile 'system001' size 512M autoextend on next 16M maxsize 3G
default tablespace USR 
  datafile 'usr001' size 128M autoextend on next 16M maxsize 3G
default temporary tablespace TEMP
  tempfile 'temp001' size 512M autoextend on next 16M maxsize 3G
  extent management local AUTOALLOCATE
undo tablespace UNDO0
  datafile 'undo001' size 512M autoextend on next 16M maxsize 3G
  extent management local AUTOALLOCATE
-- extent management local UNIFORM SIZE 1M
;

