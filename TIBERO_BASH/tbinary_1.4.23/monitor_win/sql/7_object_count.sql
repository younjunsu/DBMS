set feedback off
set linesize 132
set pagesize 100

col "OWNER" format a20

SELECT owner    "OWNER"
 , object_type  "OBJECT_TYPE"
 , count(*)     "COUNT"
FROM dba_objects
GROUP BY owner, object_type
ORDER BY owner, object_type
/

exit

