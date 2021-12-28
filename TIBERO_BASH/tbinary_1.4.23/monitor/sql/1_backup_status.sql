SET LINESIZE 132
SET PAGESIZE 100
SET FEEDBACK OFF

col "Tablespace Name" format a20
col "Datafile"  format a60
col "Status"  format a12

select a.tablespace_name "Tablespace Name"
       , a.file_name "Datafile"
       , b.status "Status"
       , to_char(b.time, 'YYYY/MM/DD HH24:MI:SS') "Backup Time"
from dba_data_files a, v$backup b
where a.file_id=b.file#
order by 1,2               
/

exit
