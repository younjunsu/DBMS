set linesize 142
set feedback off

--col "SID" format 999999999999
--col "PID" format 999999
col "User" format a15
col "IP" format a16
col "Program" format a18

SELECT
  vs.sid "SID" 
 ,vs.client_pid "PID"
 ,vs.username "User"
 ,vsw.name "Event"
 ,vsw.time_waited "Time Waited(ms)"  
 ,vsw.timeout "Timeout(ms)"
 ,vs.prog_name "Program"      
 ,vs.ipaddr "IP"
FROM  v$session vs, v$session_wait vsw
WHERE vs.sid = vsw.tid
 AND vs.type = vsw.thr_name
 AND vsw.time_waited > 0
ORDER BY vsw.time_waited
/

exit

