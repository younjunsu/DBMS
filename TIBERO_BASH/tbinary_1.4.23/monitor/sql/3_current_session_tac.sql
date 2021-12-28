set lines 160
set feedback off

col "Inst_ID" format 999999
col "Sid,Serial" format a10
col "Username" format a15
col "Status" format a10
col "Ipaddr" format a15
col "Logon_Time" format a20
col "Program" format a18
col "PGA(KB)" format 999,999
col "Wlock_Wait" format a12
@$MONITOR/sql/sqlid_format.sql

SELECT * FROM
(
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
 ORDER BY  inst_id, sid
)
UNION ALL
SELECT null
       , '[Run: ' || sum(decode(status, 'RUNNING', cnt, 0)) || ']'
                , '[Tot: ' || sum(cnt) || ']'
       ,null ,null ,null ,null ,null ,null ,null, null
FROM
 (select status
       , count(*) cnt
	from gv$session
	group by status)
/

exit

