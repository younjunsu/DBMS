SET LINESIZE 150
SET PAGESIZE 100
SET FEEDBACK OFF

col set_id for 999999
col backup_type format a13
col status  format a15
col start  format a20
col finish  format a20
col "SIZE(GB)" format 99999999999
col "SIZE(MB)" format 99999999999
col "Options" format a50

select set_id,
    backup_type,
    status,
    to_char(start_time,'YYYY/MM/DD HH24:MI:SS') as "Start",
    to_char(finish_time,'YYYY/MM/DD HH24:MI:SS') as "Finish",
    --round("SIZE(MB)"/1024,1) as "SIZE(GB)",
    "SIZE(MB)",
    backup_option as "Options"
from v$backup_set
/

exit
