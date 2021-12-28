set serveroutput on;
set feedback off
set linesize 150
set pagesize 100

col instance_number for 99
col instance_name for a25
col thread# for 99

select instance_number
  , instance_name
  , to_char(startup_time, 'YYYY/MM/DD HH24:MI:SS') startup_time
from v$instance
/

accept last_day prompt 'Enter the number of days of snapshots : '

select thread#
  , snap_id 
  , to_char(begin_interval_time,'YYYY/MM/DD HH24:MI:SS') begin_interval_time
  , to_char(end_interval_time,'YYYY/MM/DD HH24:MI:SS') end_interval_time
from _tpr_snapshot
where begin_interval_time >= sysdate - &last_day
order by 2,1 asc
/

exit
