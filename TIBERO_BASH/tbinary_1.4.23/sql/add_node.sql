/* ######## TAC Add Node Sample ######## */

create undo tablespace UNDO1
datafile 'undo101' size 512M autoextend on next 16M maxsize 3G
  extent management local AUTOALLOCATE
-- extent management local UNIFORM SIZE 1M
;

alter database add logfile thread 1 group 3 'redo131' size 100M;
alter database add logfile thread 1 group 4 'redo141' size 100M;
alter database add logfile thread 1 group 5 'redo151' size 100M;

alter database enable public thread 1;

