set feedback off
set linesize 132
set pagesize 50

col "Owner" format a15
col "Sid" format 9999
col "Object" format a35
col "Lock_type" format a15
col "Type" format a15

select SID "Sid",
       OWNER "Owner",
       OBJECT "Object",
       TYPE "Type",
       'WLOCK_DD_OBJ' Lock_type
from v$access
where sid in (
       select sess_id from v$lock
       where type='WLOCK_DD_OBJ'
       )
and owner != 'SYS'
/

exit

