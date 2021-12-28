SET LINESIZE 150
SET PAGESIZE 100
SET FEEDBACK OFF

col set_id for 999999
col backup_type format a13
col status  format a12
col start  format a20
col finish  format a20
col "SIZE(MB)" format 99999999999
col "Partial" format a13
col "Incremental" format a13
col "With Archive" format a13

select set_id,
    to_char(start_time,'YYYY/MM/DD HH24:MI:SS') as "Start",
    to_char(finish_time,'YYYY/MM/DD HH24:MI:SS') as "Finish",
    round("SIZE(KB)"/1024,1) as "SIZE(MB)",
    is_partial as "Partial",
    is_incremental as "Incremental",
    with_archivelog as "With Archive"
from v$backup_set
/

exit
