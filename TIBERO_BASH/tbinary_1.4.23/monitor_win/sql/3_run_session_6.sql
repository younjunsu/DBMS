set lines 150
set feedback off

col "Sid,Serial" format a10
col "Username" format a15
col "Status" format a10
col "Ipaddr" format a15
col "Logon_Time" format a18
col "Program" format a18
@./sql/sqlid_format.sql

SELECT * FROM
(
 SELECT  sid || ',' ||serial# "Sid,Serial"
        ,username "Username"
        ,status "Status"
        ,ipaddr "IPaddr"
        ,to_char(logon_time,'yy/mm/dd hh24:mi:ss') "Logon_Time"
        ,prog_name "Program"
        --,NVL(sql_id, prev_sql_id) "SQL_ID"
        ,NVL(sql_id, prev_sql_id) || '/' || NVL2(sql_id, sql_child_number, prev_child_number) "SQL_ID"
        ,client_pid "Client_Pid"
        ,pid "Wthr_Pid"
        ,wthr_id "Wthr_Id"
 FROM   v$session
 WHERE status <> 'READY'
 ORDER BY  1,5
)
/

exit

