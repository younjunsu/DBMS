set lines 160
set feedback off

col "Inst_ID" format 999999
col "Sid,Serial" format a10
col "Username" format a15
col "Status" format a10
col "Ipaddr" format a15
col "Logon_Time" format a20
col "Program" format a18
@$MONITOR/sql/sqlid_format.sql

SELECT inst_id "Inst_ID"
       ,sid || ',' ||serial# "Sid,Serial"
       ,username "Username"
       ,status "Status"
       ,ipaddr "IPaddr"
       ,to_char(logon_time,'yyyy/mm/dd hh24:mi:ss') "Logon_Time"
       ,prog_name "Program"
       ,NVL(sql_id, prev_sql_id) "SQL_ID"
       ,client_pid "Client_Pid"
       ,pid "Wthr_Pid"
       ,wthr_id "Wthr_Id"
FROM   gv$session
WHERE status <> 'ACTIVE'
ORDER BY inst_id, sid 
/

exit

