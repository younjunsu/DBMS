prompt ==========================
prompt  Tibero Monitoring Report 
prompt ==========================
!date

-- 1.GENERAL

set feedback off
set linesize 140

col "Instance Name"  format a15
col "Database Name"  format a15
col "Version"        format a20
col "Status"         format a12
col "NLS Character"  format a20
col "Log Mode"       format a13
col "DB Create Time" format a20
col "DB Uptime"      format a15

select i.instance_name "Instance Name"
       , d.name "Database Name"
       , v.vv "Version"
       , d.open_mode "Status"
       , c.cc "NLS Character"
       , d.log_mode "Log Mode"
       , to_char(d.create_date,'YYYY/MM/DD HH24:MI:SS') "DB Create Time"
       , floor(xx)||'d '||floor((xx-floor(xx))*24)||'h '||floor( ((xx - floor(xx))*24 - floor((xx-floor(xx))*24) )*60 )||'m' as "DB Uptime"
from v$database d
     , ( select instance_name, (sysdate-startup_time) xx
         from v$instance
       ) i
     , ( select aggr_concat(value, ' ') vv
         from v$version
         where name in ('PRODUCT_MAJOR', 'PRODUCT_MINOR', 'BUILD_NUMBER', 'STABLE_VERSION')
        ) v
     , ( select aggr_concat(value, '/') cc
         from _dd_props
         where name in ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET')
        ) c
/


set feedback off
set linesize 80
set pagesize 80

col "Parameter Name" format a40
col "Value" format a25

SELECT name "Parameter Name", value "Value" FROM sys._vt_parameter
WHERE  dflt_value <> value
       OR name in ('OPTIMIZER_MODE', 'EX_MEMORY_AUTO_MANAGEMENT', 
                   'EX_MEMORY_HARD_LIMIT','_WTHR_PER_PROC', 'UNDO_RETENTION')
ORDER BY 1
/


set linesize 130
set feedback off

col "Size" format a20

SELECT name
  , round(total/1024/1024) || '(MB)' AS "Size"
FROM v$sga
WHERE name in ('SHARED MEMORY', 'SHARED POOL MEMORY', 'Database Buffers', 'Redo Buffers')
UNION ALL
SELECT name
  , round(value/1024) || '(KB)' AS "Size"
FROM v$parameters
WHERE name = 'DB_BLOCK_SIZE'
/


set linesize 130
set feedback off

select name, round(value/1024/1024, 2) "Size(MB)"
from v$parameters
where name = 'MEMORY_TARGET'
union all
select 'SGA(Used)' name, round(sum(used)/1024/1024, 2) "Size(MB)"
from v$sga
where name in ('FIXED MEMORY', 'SHARED POOL MEMORY')
union all
select 'PGA(Allocated)' name, round(sum(value)/1024/1024, 2) "Size(MB)"
from v$pgastat
where name in ('FIXED pga memory', 'ALLOCATED pga memory')
union all
select 'PGA(Used)' name, round(value/1024/1024, 2) "Size(MB)"
from v$pgastat
where name = 'USED pga memory (from ALLOCATED)'
/


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


-- 2.SHARED MEMORY

set linesize 132
set feedback off

col "Time" format a19

SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Time"
			 ,"Physical read" 
       ,"Logical read"
       ,"Hit"
       ,CASE WHEN "Hit" > 90 then 'Good'
             WHEN "Hit" between 70 and 90 then 'Average'
             ELSE 'Not Good'
        END as "Status"
FROM
(      
 SELECT  pr1.value + pr2.value  "Physical read"   
        ,bg1.value + bg2.value + bg3.value "Logical read"   
        ,ROUND( (1 - (pr1.value + pr2.value) / (bg1.value + bg2.value + bg3.value) ) * 100, 2) "Hit"  
 FROM v$sysstat pr1, v$sysstat pr2,
      v$sysstat bg1 , v$sysstat bg2 , v$sysstat bg3
 WHERE pr1.name = 'block disk read' 
  and pr2.name = 'multi block disk read - blocks'
  and bg1.name = 'consistent block gets'
  and bg2.name = 'consistent multi gets - blocks'
  and bg3.name = 'current block gets' 
)
/


set linesize 132
set feedback off

col "Time" format a19

SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
       , 'SQL(Library) Cache' AS "Name"
       , hit AS "Hit(%)"
       , CASE WHEN hit > 90 then 'Good'
             WHEN hit between 70 and 90 then 'Average'
             ELSE 'Not Good'
         END AS "Status"
FROM ( SELECT gethitratio AS hit
        FROM v$librarycache
        WHERE namespace= 'SQL AREA' )
UNION ALL
SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
       , 'Dictionary Cache' AS "Name"
       , hit AS "Hit(%)"
       , CASE WHEN hit > 90 then 'Good'
             WHEN hit between 70 and 90 then 'Average'
             ELSE 'Not Good'
         END AS "Status"
FROM ( SELECT ROUND((1- sum(miss_cnt)/(sum(hit_cnt+miss_cnt)))*100, 2) AS hit
        FROM v$rowcache )
/

SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
      , 'Shared Cache Free Space' AS "Name"
      , ROUND(used/1024/1024) AS "Used(MB)"
      , ROUND(total/1024/1024) AS "Total(MB)"
      , ROUND((used/total)*100,2) AS "Memory Usage(%)"
FROM v$sga
WHERE name='SHARED POOL MEMORY'
/


set feedback off
set linesize 150
set pagesize 100
col name for a30
col "Gets" format 999,999,999,999
col "Misses" format 999,999,999,999
col "Sleeps" format 999,999,999
col "wait_time(s)" format 999,999,999,999

select name
       , gets "Gets"
       , misses "Misses"
       , round((misses/gets)*100, 2) "miss(%)"
       , sleeps_cnt "Sleeps"
       , decode(misses, 0, -1, round(sleeps_cnt/misses*100, 2)) "slps/miss(%)"
       , round(wait_time/1000000, 2) "wait_time(s)"
       , immediate_gets+immediate_misses "Nowait Request"
       --, immediate_misses "Nowait Miss"
       , decode(immediate_gets+immediate_misses, 0, -1, round(immediate_misses/(immediate_gets+immediate_misses)*100, 2) ) "Nowait Miss(%)"
from v$latch
where wait_time !=0
order by 7 desc
/

-- 3.SESSION

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
        --,wlock_wait "Wlock_Wait"
        ,NVL(sql_id, prev_sql_id) "SQL_ID"
        ,client_pid "Client_Pid"        
        ,pid "Wthr_Pid"
        ,wthr_id "Wthr_Id"
 FROM   v$session
 ORDER BY  1,5
)
UNION ALL
SELECT '[Run: ' || sum(decode(status, 'RUNNING', cnt, 0)) || ']'
                , '[Tot: ' || sum(cnt) || ']'
       ,null ,null ,null ,null ,null ,null ,null, null
FROM (
	select status
	       , count(*) cnt
	from v$session
	group by status
) t
/


set lines 150
set feedback off

col "Sid,Serial" format a10
col "Username" format a15
col "Status" format a10
col "Ipaddr" format a15
col "Logon_Time" format a20
col "Program" format a18
@$MONITOR/sql/sqlid_format.sql

SELECT * FROM
(
 SELECT  sid || ',' ||serial# "Sid,Serial"
        ,username "Username"
        ,status "Status"
        ,ipaddr "IPaddr"
        ,to_char(logon_time,'yyyy/mm/dd hh24:mi:ss') "Logon_Time"
        ,prog_name "Program"
        ,NVL(sql_id, prev_sql_id) "SQL_ID"
        ,client_pid "Client_Pid"
        ,pid "Wthr_Pid"
        ,wthr_id "Wthr_Id"
 FROM   v$session
 WHERE status <> 'ACTIVE'
 ORDER BY  1,5
)
/


set lines 160
set feedback off
col "Sid,Serial" format a10
col "Staus" format a10
col "Username" format a9
col "Program" format a15
col "PGA(MB)" format 999,999
col "Wlock_Wait" format a12
col "SQL" format a6
col "Wait_Event" format a17
col "Wait_Time(s)" format 99999999
col "Object_Name" format a20
@$MONITOR/sql/sqlid_format.sql

 SELECT  s.sid || ',' ||s.serial# "Sid,Serial"
        ,username "Username" 
        ,s.status "Staus"
        ,s.prog_name "Program"
        ,round(pga_used_mem/1024/1024,2) "PGA(MB)"        
        ,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
        ,decode(s.command, 1, 'SELECT', 2, 'INSERT', 3, 'UPDATE', 4, 'DELETE', 5, 'CALL', 'ETC') "SQL"
        ,s.wlock_wait "Wlock_Wait"
        ,e.name "Wait_Event"
        , o.owner||'.'||o.object_name "Object_Name"
        ,round(s.wait_time/10) "Wait_Time(s)"
 FROM   v$session s, v$event_name e, dba_objects o
 WHERE s.wait_event=e.event#(+)
       and s.row_wait_obj_id=o.object_id(+)
       and s.status <> 'ACTIVE'
 ORDER BY  1
/


set linesize 120
set pagesize 100
set feedback off

col sid format 99999
col username format a15
col piece format 99999
col "Type" format a10
col "SQL" format a70

SELECT  vs.sid ,  vs.username, vst.piece, 
        vs.Type "Type", vst.sql_text "SQL"
FROM 
    v$session vs, 
    v$sqltext vst,
    (SELECT tid FROM sys._vt_mytid) mys
WHERE vs.sql_id=vst.sql_id
  AND vs.sid <> mys.tid
  AND vs.status='RUNNING'
ORDER BY vs.sid, vst.piece
/


set feedback off
set linesize 150

col "SID" format 999999
col "User" format a15
col "OBJ" format a35
col "Status" format a7
col "Used_blk" format 999,999,999
col "Usn" format 99999
col "Time" format a8
col "[SQL_ID]Text" format a36

SELECT 0 "SID"
        ,'[ToTal : ' || count(*) || ' ]' "User"
        ,null "OBJ"
        ,null "Status"
        ,0 "Usn"
        ,0 "Used_blk"
        ,null "Time"
        ,null "[SQL_ID]Text"
FROM v$transaction
UNION ALL
SELECT
  distinct vt.sess_id
 ,decode(va.type,'INDEX', ' --> INDEX : ', vs.username)
 ,va.OWNER || '.' ||  va.object
 ,vs.status
 ,vt.usn
 ,vt.used_blk
 ,floor((sysdate - vt.start_time)*24) || ':'||
       lpad(floor(mod((sysdate - vt.start_time)*1440, 60)),2,0) ||':'||
       lpad(floor(mod((sysdate - vt.start_time)*86400,60)),2,0)
 ,'[' || nvl(vs.sql_id,vs.prev_sql_id) ||'] '|| vst.sql_text "SQL_ID"
FROM
  v$session vs,
  v$transaction vt,
  (select * from v$sqltext where piece=0) vst,
  v$access va
WHERE
     vt.sess_id = vs.sid
 and vt.sess_id = va.sid
 and nvl(vs.sql_id,vs.prev_sql_id) = vst.sql_id(+)
ORDER BY "Time", "SID" , "User" DESC
/


set feedback off
set linesize 130

col "COUNT" format 999,999

select sid "SID", count(*) "COUNT" 
from v$open_cursor 
group by sid 
/


-- 4.WAIT EVENT/LOCK

set feedback off
set linesize 132
set pagesize 20

col "Blocking User" format a15
col "Waiting User" format a15
col "Blocking Sid" format 999999999999
col "Waiting Sid" format 99999999999
col "Lock Type" format a12
col "Holding mode" format a15
col "Request mode" format a15
@$MONITOR/sql/sqlid_format.sql

SELECT bs.user_name "Blocking User"
      ,ws.user_name "Waiting User"
      ,bs.sess_id "Blocking Sid"
      ,ws.sess_id "Waiting Sid"
      ,wk.type "Lock Type"
      ,DECODE(hk.lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (hk.lmode) )  "Holding mode"
      ,DECODE(wk.lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (wk.lmode) )  "Request mode"
      ,NVL(bs.sql_id, bs.prev_sql_id) "SQL_ID"
   FROM vt_wlock hk, 
        vt_session bs, 
        vt_wlock wk, 
        vt_session ws
  WHERE wk.status = 'WAITER'
    and hk.status = 'OWNER'
    and hk.lmode > 1
    and wk.type = hk.type
    and wk.id1 = hk.id1
    and wk.id2 = hk.id2
    and wk.thr_id = ws.vtr_tid
    and hk.thr_id = bs.vtr_tid
  ORDER BY 1,3
/


set feedback off
set linesize 150
set pagesize 100
col "Sid-Path" for a40

select path "Sid-Path"
       , lev "Level"
       , isleaf
       , type
       , id1
       , id2
       , lmode
       , requested
from (
select  substr(sys_connect_by_path(thr_id, '/'), 2) path
       ,level lev
       ,connect_by_isleaf as isleaf
       ,connect_by_iscycle as iscycle  
       , l.*
from v$lock l
start with lmode > 0 and requested =0
connect by nocycle
         prior type = type
         and prior id1 = id1
         and prior id2 = id2
         and prior thr_id != thr_id
         and requested > 0
--order siblings by thr_id
) t
where lev > 1 and iscycle = 0
order by type, path
/

set feedback off
set linesize 132
set pagesize 50

col "User" format a15
col "Sid" format 9999
col "Object" format a35
col "Status" format a8
col "Lock_time" format a15
col "Lock mode" format a15
@$MONITOR/sql/sqlid_format.sql


SELECT s.sess_id  "Sid"
      ,s.status "Status"
      ,s.user_name "User"
      ,o.owner|| '.' ||o.object_name "Object"
      ,FLOOR((sysdate - vt.start_time)*24) || ':'||
        LPAD(FLOOR(MOD((sysdate - vt.start_time)*1440, 60)),2,0) ||':'||
        LPAD(FLOOR(MOD((sysdate - vt.start_time)*86400,60)),2,0) AS "Lock_time"
      ,DECODE(lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (lmode) )  "Lock mode"
      ,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
 FROM vt_wlock l, 
      vt_session s,  
      dba_objects o ,
      vt_transaction vt
WHERE l.type='WLOCK_DML'
  AND l.thr_id = s.vtr_tid
  AND l.id1 = o.object_id (+)
  AND l.thr_id = vt.sess_id order by "Lock_time" DESC
/


set feedback off
set linesize 132
set pagesize 50

col "Owner" format a15
col "Sid" format 9999
col "Object" format a35
col "Lock_type" format a15
col "Type" format a15

select SID "Sid",
       OWNER "Owner",
       OBJECT "Object",
       TYPE "Type",
       'WLOCK_DD_OBJ' Lock_type
from v$access
where sid in (
       select thr_id from v$lock
       where type='WLOCK_DD_OBJ'
       )
and owner != 'SYS'
/


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


set feedback off
set linesize 130
set pagesize 50

--col value format 99,999,999,999,999,999

SELECT * FROM
(
  SELECT * FROM v$sysstat 
  WHERE value > 0 
  ORDER BY value DESC
)
WHERE ROWNUM < 40 
/
 

set linesize 132
set feedback off
set pagesize 50
col size for 9999999999

SELECT * FROM 
(
  SELECT b.name AS name
      , SUM(num) AS num
      , SUM("SIZE") AS "SIZE"
      , ROUND(SUM(a.time)/1000000,4) AS time_sec
  FROM vt_jcntstat a, vt_jcntstat_name b
  WHERE a.jcnt# = b.jcnt#
  GROUP BY b.name, a.jcnt#
  HAVING (SUM(num) > 0 OR SUM("SIZE") > 0 OR SUM(a.time) > 0 )
  ORDER BY time_sec DESC 
)
WHERE time_sec > 0 
AND ROWNUM < 40
/


set linesize 80
set feedback off

SELECT rlsr "Redo entries", rent "Redo space requests", ROUND(100*(1-rlsr/rent),2) "Redo NoWait %"
FROM 
 (SELECT value rlsr FROM v$sysstat WHERE name = 'redo log space requests'),
 (SELECT value rent FROM v$sysstat WHERE name = 'redo entries')
/



-- 5.SPACE

set feedback off
set linesize 132

col "Control Files" format a87


SELECT name  "Control Files" FROM v$controlfile
/


set feedback off
set linesize 100

col "Group#" format 9999999
col "Member" format a60
col "Type"   format a8
col "Size(MB)" format 9,999,999

SELECT vl.group# "Group#", vlf.member "Member", vlf.type "Type" , vl.bytes/1024/1024 as "Size(MB)"
FROM v$log vl, v$logfile vlf
WHERE vl.group# = vlf.group#
/


set feedback off
set linesize 120
set pagesize 100

col "Tablespace Name" format a20
col "File Name" format a60
col "Size(MB)" format 999,999,999
col "MaxSize(MB)" format 999,999,999

SELECT *
FROM (
	SELECT tablespace_name as "Tablespace Name",
	           file_name as "File Name",
	           bytes/1024/1024 as "Size(MB)",
	           maxbytes/1024/1024 as "MaxSize(MB)"
	FROM dba_data_files
	UNION ALL
	SELECT tablespace_name as "Tablespace Name",
	       file_name as "File Name" ,
	       bytes/1024/1024 "Size(MB)",
	       maxbytes/1024/1024 "MaxSize(MB)"
	FROM dba_temp_files
)
ORDER BY 1,2
/


set feedback off
set linesize 150
set pagesize 100

col "Tablespace Name" format a20
col "Bytes(MB)"       format 999,999,999
col "Used(MB)"        format 999,999,999
col "Percent(%)"      format 9999999.99
col "Free(MB)"        format 999,999,999
col "Free(%)"         format 9999.99
col "MaxBytes(MB)"       format 999,999,999

SELECT ddf.tablespace_name "Tablespace Name",
       ddf.bytes/1024/1024 "Bytes(MB)",
       (ddf.bytes - dfs.bytes)/1024/1024 "Used(MB)",
       round(((ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) "Percent(%)",
       dfs.bytes/1024/1024 "Free(MB)",
       round((1 - ((ddf.bytes - dfs.bytes) / ddf.bytes)) * 100, 2) "Free(%)",
       ROUND(ddf.MAXBYTES / 1024/1024,2) "MaxBytes(MB)"      
FROM
 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
   FROM   dba_data_files
   GROUP BY tablespace_name) ddf,
 (SELECT tablespace_name, sum(bytes) bytes
   FROM   dba_free_space
   GROUP BY tablespace_name) dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
ORDER BY ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC
/


set linesize 130
set feedback off

col "Tablespace Name" format a20
col "Size(MB)" format 999,9999,999.99
col "MaxSize(MB)" format 999,9999,999.99

SELECT tablespace_name "Tablespace Name",
       SUM(bytes)/1024/1024 "Size(MB)",
       SUM(maxbytes)/1024/1024 "MaxSize(MB)"
FROM dba_temp_files
GROUP BY tablespace_name
ORDER BY 1
/


set linesize 140
set pagesize 100
set feedback off

col tablespace_name format a15
col "Undoseg Activity" format a28

SELECT dr.segment_ID
       , dr.tablespace_name
       , dr.status
       , vr.extents
       , round((vr.rssize * pt.value)/1024/1024,1) "RSSIZE(MB)"
       , vr.curext
       , round((vr.cursize * pt.value)/1024/1024,1) "CURSIZE(MB)"
       --, vr.cursize
       , vr.shrinks
       , vr.wraps
       , vr.extends
       , vr.xacts
FROM dba_rollback_segs dr
  , v$rollstat vr
  , (select value from _vt_parameter 
    where name = 'DB_BLOCK_SIZE') pt
WHERE dr.segment_id = vr.usn
ORDER BY 5, 1
/

SELECT 'Online Undosegs Cnt' AS "Undoseg Activity", count(*) AS "COUNT" FROM v$rollstat
UNION ALL
SELECT 'Active Undosegs Cnt', count(*) FROM v$rollstat WHERE xacts>0
UNION ALL
SELECT name, value from v$sysstat WHERE name like 'undo segment seqno%'
/


set linesize 132
set feedback off

col tablespace_name format a15
col "SQL Type" format a10
@$MONITOR/sql/sqlid_format.sql

SELECT vs.sid,
       vs.serial#,
       dr.segment_id,
       DECODE(vst.command_type, 1, 'SELECT'
             , 2, 'INSERT'
             , 3, 'UPDATE'
             , 4, 'DELETE'
             , 5, 'CALL', 0) "SQL Type",
       vst.sql_id,
       dr.tablespace_name,
       vt.used_blk,
       vr.curext,
       vr.cursize,
       vr.xacts
FROM dba_rollback_segs dr,
     v$rollstat vr,
     v$transaction vt,
     v$session vs,
     (select distinct command_type, sql_id from v$sqltext) vst
WHERE dr.segment_id=vr.usn
    and vr.usn=vt.usn
    and vt.sess_id=vs.sid
    and nvl(vs.sql_id, vs.prev_sql_id)=vst.sql_id
/

set feedback off
set linesize 150
set pagesize 100

col username for a15 
col segtype for a15 

SELECT sid
      , username
      , tempseg.sql_id
      , segtype
      , round( (blocks*pt.value)/1024/1024, 2) AS "TEMP(MB)"
      , vst.sql_text
FROM(
  SELECT session_num sid
        , username
        , sql_id
        , segtype
        , sum(blocks) blocks
  FROM   v$tempseg_usage
  GROUP BY session_num, username, sql_id, segtype
) tempseg
, v$sqltext vst
, (select value from _vt_parameter
   where name = 'DB_BLOCK_SIZE') pt
WHERE tempseg.sql_id = vst.sql_id
AND vst.piece = 0
order by sid
/ 


set feedback off
set linesize 150
set pagesize 100

col "Temp Name" format a15

select tbs "Temp Name"
       , tot "Total(MB)"
       , use "Used(MB)"
       , tot-use "Free(MB)"
       , round( (tot-use)/tot*100, 1) "Free(%)"
       , ma "Max(MB)"
from (       
	SELECT tf.tablespace_name tbs,
	       round(tf.bytes/1024/1024,2) tot ,
	       nvl2( tu.blocks, round((tu.blocks*pt.value)/1024/1024,2), 0) use,
	       ROUND(tf.MAXBYTES/1024/1024,2) ma      
	FROM
	 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
	   FROM   dba_temp_files
	   GROUP BY tablespace_name) tf,
	 (SELECT tablespace as tablespace_name, sum(blocks) blocks
	   FROM   v$tempseg_usage
	   GROUP BY tablespace) tu
	 ,(select value from _vt_parameter
	   where name = 'DB_BLOCK_SIZE') pt   
	WHERE tf.tablespace_name = tu.tablespace_name(+)
) t
order by 1
/ 



-- 6.I/O

set lines 150
set pagesize 40
set feedback off

col tablespace_name format a15
col file_name       format a50
col phyrds          format 999,999,999
col phywrts         format 999,999,999
col "Read(%)"       format 99999.9
col "Write(%)"      format 99999.9
col "Total_IO(%)"   format 9999.9
col "AvgTime(s)" format 9999.999

SELECT fl.tablespace_name,
       df.name file_name,
       fs.phyrds,
       fs.phywrts,
       round((PHYRDS/tot.rds)*100, 1) "Read(%)",
       round((PHYWRTS/decode(tot.wrts, 0, 1, tot.wrts))*100, 1) "Write(%)",
       round((phyrds + phywrts)/(tot.rds+tot.wrts)*100, 1) "Total_IO(%)" ,
       round(fs.avgiotim/1000,3) "AvgTime(s)"
FROM  v$datafile df
     ,v$filestat fs
     ,dba_data_files fl
     ,(select sum(phyrds) rds, sum(phywrts) wrts from v$filestat) tot
WHERE df.file# = fs.file#
  AND df.file# = fl.file_id
ORDER BY 1,2
/

set linesize 132
set pagesize 100
set feedback off

col "User" format a15
col "Program" format a13
col "Sid" format 999999

SELECT s.sid "Sid"
      ,s.username "User"
      ,s.prog_name "Program"
      ,si.block_gets
      ,si.consistent_gets
      ,si.physical_reads
      ,si.block_changes
      ,si.consistent_changes
FROM  v$session s,
      v$session_io si
WHERE  s.sid = si.sid
ORDER BY s.username, s.sid
/


set lines 132
set feedback off


SELECT 'Hourly 00  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23' AS "LOG HISTORY (Since Last Month)" FROM dual
UNION ALL
SELECT '-------------------------------------------------------------------------------------------------------' FROM dual
UNION ALL
SELECT TO_CHAR(first_time,'MM/DD') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'00',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'01',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'02',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'03',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'04',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'05',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'06',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'07',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'08',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'09',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'10',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'11',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'12',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'13',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'14',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'15',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'16',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'17',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'18',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'19',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'20',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'21',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'22',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'23',1,0)),'99') ||'|'   
       as Loghistory 
FROM v$archived_log
WHERE first_time >= add_months(sysdate,-1)
GROUP BY TO_CHAR(first_time,'MM/DD')
UNION ALL
SELECT NULL FROM DUAL
UNION ALL
SELECT '[ARCHIVED LOG COUNT : ' || TO_CHAR(COUNT(*), 999) || ']' AS CNT
FROM v$archived_log
WHERE first_time >= add_months(sysdate,-1)
/



-- 7.OBJECT

set feedback off
set linesize 132
set pagesize 100

col "OWNER" format a20

SELECT owner    "OWNER"
 , object_type  "OBJECT_TYPE"
 , count(*)     "COUNT"
FROM dba_objects
GROUP BY owner, object_type
ORDER BY owner, object_type
/


set feedback off
set linesize 132
set pagesize 100

col "Owner" format a20

SELECT owner    "Owner"
 , object_type  "Object type"
 , status       "Status"
 , count(*)     "Count"
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY owner, object_type, status
ORDER BY owner, object_type, status
/


set feedback off
set linesize 132
set pagesize 100

col "Owner" format a20
col "Object name" format a50
col "Last DDL Time" format a19

SELECT owner     "OWNER"
 , object_type   "Object type"
 , object_name   "Object name"
 , status        "Status"
 , to_char(last_ddl_time, 'YYYY-MM-DD HH24:MI:SS') "Last DDL Time"
FROM dba_objects
WHERE status = 'INVALID'
AND object_type != 'SYNONYM'
ORDER BY owner, object_type, object_name, status
/


SET LINESIZE 132
SET PAGESIZE 120
SET FEEDBACK OFF

col "Owner" format a20
col "Segment Name" format a30
col "Tablespace Name" format a20
col "Extents" format 999,999,999
col "Size(MB)" format 999,999,999

SELECT owner "Owner",
        segment_name as "Segment Name",
        segment_type as "Segment Type",
        tablespace_name as "Tablespace Name",
        extents as "Extents",
        round(bytes/1024/1024,2) as "Size(MB)"
FROM
(
        SELECT  owner,
                segment_name,
                segment_type,
                tablespace_name,
                extents,
                bytes
        FROM dba_segments d
        WHERE owner not in ('SYS','SYSGIS','SYSCAT')
        ORDER BY bytes desc
)
WHERE rownum <= 50
/


-- 8.SQL

set linesize 132
set feedback off

@$MONITOR/sql/sqlid_format.sql

-- Top 5 SQL Ordered by Elapsed Time
prompt  ========  Top 10 SQL Ordered by Elapsed Time =========

select * from
(
select round(ELAPSED_TIME/1000000,3) as "Elapsed_Time(s)",
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/EXECUTIONS/1000,3) as "Elap/Exec(ms)",
       SQL_ID "SQL_ID"
from v$sqlarea
where ELAPSED_TIME > 0
and EXECUTIONS > 0
order by 1 desc
) where rownum <=10
/

prompt
prompt  ========  Top 10 SQL Ordered by gets =============

select * from
(
select BUFFER_GETS,
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/1000000,3) "Elapsed_Time(s)",
       SQL_ID "SQL_ID"
from v$sqlarea
where ELAPSED_TIME > 0
and EXECUTIONS>0
--and rownum <=10
order by 1 desc
) where rownum <=10
/

prompt
prompt  ========  Top 10 SQL Ordered by Elap/Exec(ms) =============

select * from
(
select round(ELAPSED_TIME/EXECUTIONS/1000,3) as "Elap/Exec(ms)",
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/1000000,3) "Elapsed_Time(s)",
       SQL_ID "SQL_ID"
from v$sqlarea
where ELAPSED_TIME > 0
and EXECUTIONS>0
--and rownum <=10
order by 1 desc
) where rownum <=10
/

set lines 150
set pages 120
set feedback off
@$MONITOR/sql/sqlid_format.sql

select 'Pattern #' || lpad(row_number() over(order by cnt desc),3,'0') pattern_no,
 sql_id, sql_pattern, cnt
   from(
    select substr(sql_text,1,40) sql_pattern, min(SQL_ID) SQL_ID, count(*) cnt 
    from v$sqlarea 
    group by substr(sql_text,1,40)
    having count(*) > 5
   )order by cnt

/


exit
