set feedback off
set linesize 132
set pagesize 100

col "Owner" format a20
col "Object name" format a50
col "Last DDL Time" format a19

SELECT owner     "OWNER"
 , object_type   "Object type"
 , object_name   "Object name"
 , status        "Status"
 , to_char(last_ddl_time, 'YYYY-MM-DD HH24:MI:SS') "Last DDL Time"
FROM dba_objects
WHERE status = 'INVALID'
AND object_type != 'SYNONYM'
ORDER BY owner, object_type, object_name, status
/

exit

