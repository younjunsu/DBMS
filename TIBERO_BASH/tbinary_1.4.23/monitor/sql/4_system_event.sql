set linesize 132
set feedback off
set pagesize 40

SELECT name, time_waited, total_waits, total_timeouts, average_wait, max_wait
FROM   
(
  SELECT name, total_waits, total_timeouts, time_waited, average_wait, max_wait
   FROM   v$system_event
  WHERE  name not in 
     ('WE_CONN_IDLE', 'WE_NOEVENT', 'WE_LARC_IDLE', 'WE_SEQ_IDLE', 
      'WE_CKPT_IDLE', 'WE_LGWR_IDLE', 'WE_DBWR_IDLE')
  ORDER BY time_waited desc, total_waits desc, name
)
WHERE rownum < 30
/

exit

