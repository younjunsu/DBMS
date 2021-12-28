set lines 150
set feedback off

col "Sid,Serial" format a10
col "Username" format a15
col "Status" format a10
col "Ipaddr" format a15
col "Logon_Time" format a20
col "Program" format a18
--col "SQL_ID" format 9999999999999999999
@$MONITOR/sql/sqlid_format.sql

SELECT * FROM
(
 SELECT  sid || ',' ||serial# "Sid,Serial"
        ,username "Username"
        ,status "Status"
        ,ipaddr "IPaddr"
        ,to_char(logon_time,'yyyy/mm/dd hh24:mi:ss') "Logon_Time"
        ,prog_name "Program"
        --,pga_used_mem/1024 "PGA(KB)"
        ,wlock_wait "Wlock_Wait"
        ,NVL(sql_id, prev_sql_id) "SQL_ID"
      --  ,client_pid "Client_Pid"        
        ,pid "Wthr_Pid"
       -- ,wthr_id "Wthr_Id"
 FROM   v$session
 ORDER BY  1,5
)
UNION ALL
SELECT '[Run: ' || sum(decode(status, 'RUNNING', cnt, 0)) || ']'
       , '[Tot: ' || sum(cnt) || ']'
       ,null ,null ,null ,null ,null,null,null
FROM (
    select status
           , count(*) cnt
    from v$session
    group by status
) t
/

exit

