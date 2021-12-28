set feedback off
set linesize 130
set pagesize 40
col value format 99,999,999,999,999,999
col tid format 9999
col "DESC" format a50

select tid, 
       "DESC", 
       total_waits,
       total_timeouts,
       time_waited,
       average_wait,
       max_wait 
from V$SESSION_EVENT
where 1=1 
and time_waited > 0 
order by 1,time_waited desc
/
exit
