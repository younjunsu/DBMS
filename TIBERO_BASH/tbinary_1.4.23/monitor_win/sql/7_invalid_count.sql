set feedback off
set linesize 132
set pagesize 100

col "Owner" format a20

SELECT owner    "Owner"
 , object_type  "Object type"
 , status       "Status"
 , count(*)     "Count"
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY owner, object_type, status
ORDER BY owner, object_type, status
/

exit

