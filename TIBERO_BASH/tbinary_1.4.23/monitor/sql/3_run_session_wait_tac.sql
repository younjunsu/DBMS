set lines 160
set feedback off
col "Inst_ID" format 999999
col "Sid,Serial" format a10
col "Staus" format a10
col "Username" format a9
col "Program" format a15
col "PGA(MB)" format 999,999
col "Wlock_Wait" format a12
col "SQL" format a6
col "Wait_Event" format a17
col "Wait_Time(s)" format 99999999
@$MONITOR/sql/sqlid_format.sql


 SELECT  s.inst_id "Inst_ID"
        ,s.sid || ',' ||s.serial# "Sid,Serial"
        ,username "Username" 
        ,s.status "Staus"
        ,s.prog_name "Program"
        ,round(pga_used_mem/1024/1024,2) "PGA(MB)"        
        ,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
        ,decode(s.command, 1, 'SELECT', 2, 'INSERT', 3, 'UPDATE', 4, 'DELETE', 5, 'CALL', 'ETC') "SQL"
        ,s.wlock_wait "Wlock_Wait"
        ,e.name "Wait_Event"
        ,round(s.wait_time/10) "Wait_Time(s)"
 FROM   gv$session s, v$event_name e
 WHERE s.wait_event=e.event#(+)
       and s.status <> 'ACTIVE'
 ORDER BY s.inst_id, s.sid 
/

exit
