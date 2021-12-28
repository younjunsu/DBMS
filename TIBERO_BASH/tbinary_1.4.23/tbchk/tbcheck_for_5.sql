/*------------------------------------------------------------------------------
# Tibero 정기점검 SQL 
#-------------------------------------------------------------------------------
# @File name      : tbcheck.sql
# @Contents       : Tibero RDBMS CSR Ver1.4
# @Created by     : Kim shi youl
# @Created date   : 2010.07.01
# @Team           : DB Tech
# @Modifed History 
# ------------------------------------------------------------------------------
# 2010.07.31 Kim shi youl                 (Ver1.0)
# 2011.03.15 Gim gwon hwan Modified       (Ver1.1)
# 2011.03.17 Gim gwon hwan Modified       (Ver1.2)
# 2011.03.25 Gim gwon hwan Modified       (Ver1.3)
# 2013.03.18 GC Lee Modified              (Ver1.4)
# 2017.03.20 Yeo Han Na Modified          (Ver1.4.8)
# -----------------------------------------------------------------------------*/

set pages 500;

	prompt ############################
	prompt # Tibero RDBMS CSR (Ver1.4)#
	prompt ############################
	prompt 
	
	prompt ########0. Tibero Info########
	prompt ########  0.1 Tibero Version########
	!tbboot -version
	
	prompt ########  0.2 Tibero License########
	set feedback off
	set linesize 150
	
	col "LICENSE_VERSION"   format a15
	col "LICENSEE" 					format a15
	col "LICENSE_TYPE"      format a12
	col "PRODUCT_NAME"			format a12
	col "PRODUCT_VERSION" 	format a15
	col "EDITION"  					format a10
	col "ISSUE_DATE"  			format a10
	col "EXPIRE_DATE"  			format a11
	col "LIMIT_USER"  			format a10
	col "LIMIT_CPU"  				format a10
	col "HOST"  						format a15
	
	select * from v$license;
	
	prompt
	prompt ########  0.3 Tibero Instance########
	set feedback off
	set linesize 150
	
	col "Instance Name"    format a15
	col "Database Name"    format a15
	col "Version"  format a12
	col "Status"           format a8
	col "NLS_Characterset" format a15
	col "Log Mode" format a13
	col "DB Create Time"  format a15
	
	SELECT
	   instnm     "Instance Name"
	 , dbnm       "Database Name"
	 , major || minor||' '  || bldnum "Version"
	 , inststatus "Status"
	 , nls  "NLS_Characterset"
	 , lmode   "Log Mode"
	 , cdate    "DB Create Time"
	FROM
	  (SELECT instance_name instnm, status inststatus FROM vt_instance)
	 ,(SELECT name dbnm, log_mode lmode , create_date cdate FROM v$database)
	 ,(SELECT value nls FROM sys._dd_props WHERE name = 'NLS_CHARACTERSET')
	 ,(SELECT value major FROM vt_version WHERE name = 'PROTOCOL_MAJOR')
	 ,(SELECT value minor FROM vt_version WHERE name = 'PROTOCOL_MINOR')
	 ,(SELECT value bldnum FROM vt_version WHERE name in 'BUILD_NUMBER');
	
	prompt
	prompt  ########1. TSM Info ########
	set linesize 150;
	set feedback off;
	
	col 'TSM Info' for A50
	
	SELECT 'Current Time                : '|| TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "TSM Info"
	FROM DUAL
	UNION ALL
	SELECT 'TSM(Tibero Shared Memory)   : '||total/1024/1024 || ' M'  
	as "TSM(Tibero Shared Memory)"
	FROM   v$sga
	WHERE  name = 'SHARED MEMORY'
	UNION ALL
	SELECT 'Shared Cache Size           : '||ROUND(total/1024/1024,0) || ' M'
	FROM   v$sga
	WHERE  name = 'SHARED POOL MEMORY'
	UNION ALL
	SELECT 'Database Buffer Size        : '||value/1024/1024 || ' M' 
	FROM   _vt_parameter 
	WHERE name='DB_CACHE_SIZE'
	UNION ALL            
	SELECT 'DB Block Size               : '||value/1024 || ' K'
	FROM   _vt_parameter
	WHERE  name = 'DB_BLOCK_SIZE'
	UNION ALL
	SELECT 'Redo Log BUffer Size        : '||value/1024/1024 || ' M'
	FROM   _vt_parameter
	WHERE  name = 'LOG_BUFFER'
	UNION ALL
        SELECT 'WPM(Working Process Memory) : ' || round((to_number(vt.value) - s.total)/1024/1024,0)   || ' M' 
        AS WPM
        FROM v$sga s, _vt_parameter vt
        WHERE vt.NAME = 'MEMORY_TARGET' AND s.name = 'SHARED MEMORY';
--	SELECT 'WPM(Working Process Memory) : ' || ROUND(value/1024/1024,0)  || ' M'
--	FROM _vt_parameter WHERE name='EX_MEMORY_HARD_LIMIT';
	
	prompt
	prompt  ########2. DB performance ########
	prompt  ########   2.1 Buffer Cache Hit Ratio########
	set linesize 500;
	set feedback off;
	SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time"
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
	        ,ROUND( (1 - ( (pr1.value + pr2.value) / (bg1.value + bg2.value + bg3.value) ) ) * 100, 2) "Hit"  
	 FROM v$sysstat pr1, v$sysstat pr2,
	      v$sysstat bg1 , v$sysstat bg2 , v$sysstat bg3
	 WHERE pr1.name = 'block disk read' 
	  and pr2.name = 'multi block disk read - blocks'
	  and bg1.name = 'consistent block gets'
	  and bg2.name = 'consistent multi gets - blocks'
	  and bg3.name = 'current block gets' 
	);
	
	prompt
	prompt  ########   2.2 SQL Cache Hit Ratio########
	set linesize 500;
	set feedback off;
/*tibero old version */
/*	SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time", name, hit_ratio, total_cnt, hit_cnt, miss_cnt 
	FROM v$librarycache where name = 'SQL AREA';
*/

/*tibero new version */
	SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time",	NAMESPACE, GETS, GETHITS, GETHITRATIO, PINS, PINHITS, PINHITRATIO
	FROM v$librarycache where namespace = 'SQL AREA';

	prompt
 	prompt  ########   2.3 Dictionary Cache Hit Ratio########
	set linesize 500
	set feedback off
	SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time", 
	ROUND( ( sum(hit_cnt) - sum(miss_cnt) ) / sum(hit_cnt) * 100,1)
	 "Dictionary Cache Hit Ratio(%)" 
	FROM v$rowcache;

	prompt
 	prompt  ########   2.4 Shared Cache Free Space########
	set linesize 500;
	set feedback off;
	SELECT 
	 TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time",
	 round(total/1024/1024,1)  "Shared Cache Total (MB)", 
	 round(used/1024/1024,1)  "Used (MB)", 
	 round((total - used)/1024/1024,1) "free (MB)" ,
	 (round((total - used)/1024/1024,1)/round(total/1024/1024,1))*100 "free (%)"
	FROM v$sga WHERE name='SHARED POOL MEMORY';

	prompt
 	prompt  ########3. space usage########
 	prompt  ########  3.1 tablespace free space ( monitoring 쉘 4번 )########
	set linesize 500;
	set feedback off;

	col "Tablespace Name" format a20;
	col "Bytes(MB)"       format 999,999,999;
	col "MaxBytes(MB)"    format 999,999,999;
	col "Used(MB)"        format 999,999,999;
	col "Percent(%)"      format 9999999.99;
	col "Free(MB)"        format 999,999,999;
	col "Free(%)"         format 999.99;

	select TO_CHAR(sysdate, 'yyyy/mm/dd hh24:mi:ss') "Current Time",
	  ddf.tablespace_name "Tablespace Name",
	  ddf.bytes/1024/1024 "Bytes(MB)",
	  ddf.maxbytes/1024/1024 "MaxBytes(MB)",
	  (ddf.bytes - dfs.bytes) /1024/1024 "Used(MB)",
	  round( ( (ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) "Percent(%)",
	  dfs.bytes/1024/1024 "Free(MB)",
	  round( (1 - ( (ddf.bytes - dfs.bytes) / ddf.bytes) ) * 100, 2) "Free(%)",
	  round( (1 - ( (ddf.bytes - dfs.bytes) / greatest(ddf.bytes, ddf.maxbytes) ) ) * 100, 2) "Free_REAL(%)"
	from ( select tablespace_name,
	           sum(bytes) bytes,
	           sum(MAXBYTES) maxbytes
	      from dba_data_files
	     group by tablespace_name) ddf,
	  ( select tablespace_name,
	            sum(bytes) bytes,
	            0 maxbytes
	       from dba_free_space
	      group by tablespace_name) dfs
	where ddf.tablespace_name = dfs.tablespace_name
	order by ( (ddf.bytes-dfs.bytes) /ddf.bytes) desc;

 	prompt  ########  3.2 undo segment usage ( monitoring 쉘 8번 )########
	set linesize 500;
	set feedback off;
	col "tablespace_name" format a15;
	col "status" format a10;

	SELECT 
	  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time"
	,  dr.segment_ID, dr.tablespace_name, dr.status, vr.extents
	, (vr.rssize * pt.value)/1024 "rssize[K]"
	, vr.curext, vr.cursize,  vr.xacts
	FROM 
	dba_rollback_segs dr, v$rollstat vr,
	(SELECT value FROM _vt_parameter WHERE name='DB_BLOCK_SIZE') pt
	WHERE dr.segment_id=vr.usn;

	prompt
	prompt  ########4. DISK I/O ########
	prompt  ########  4.1 File I/O ( monitoring 쉘 5번 )########
	set linesize 500;
	set feedback off;
	col "TABLESPACE_NAME" format a20;
	col "name" format a50;

	SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time",
		fl.tablespace_name, df.name, fs.phyrds, fs.phywrts, 
		 round((PHYRDS / (SELECT sum(phyrds) FROM v$filestat))
			       *100, 1)  "P_READ(%)", 
		 round((PHYWRTS /
			  DECODE((SELECT sum(phywrts) FROM v$filestat), 0, 1,
				       (SELECT sum(phywrts)FROM v$filestat)))*100, 1)
					"P_WRITE(%)", 
		 round((phyrds + phywrts) / 
			  (SELECT sum(phyrds) + sum(phywrts) FROM v$filestat)
			       * 100, 1)  "TOTAL IO (%)" , 
		 round(fs.AVGIOTIM/1000,3) "AVG_TIME(msec)" 
	FROM	V$DATAFILE df, V$FILESTAT fs, dba_data_files fl 
	WHERE	df.file# = fs.file# AND df.file# = fl.file_id 
	ORDER BY phyrds+phywrts DESC;

	prompt
	prompt  ########  4.2 Online Redo Log switch Count########
	set linesize 500;
	set feedback off;
	--col LOGHISTORY HEADING "Online Log_history : 00(h)01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23" ;

SELECT 'Hourly  00  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23' loghistory FROM dual
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
GROUP BY TO_CHAR(first_time,'MM/DD')
/	
	prompt
	prompt  ########5. current session info########
	prompt  ########  5.1 current session count########
	set linesize 500;
	set feedback off;

  SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time",
        a.pga "ASP(Active Session PGA)",
        m.max "MAX Session" ,
        (a.acs + b.run) "Total Session" ,
        b.run "Running Session" ,
        c.recover "Recover Session"
  FROM
        (select wp.value * wt.value as max
                from (select name, value from _VT_PARAMETER where name='WTHR_PROC_CNT' ) wp
                , (select name, value from _VT_PARAMETER where name='_WTHR_PER_PROC') wt) m ,
        (SELECT SUM(pga_used_mem) pga,
        COUNT(*) acs  FROM v$session WHERE status='ACTIVE') a ,
        (SELECT COUNT(*) run FROM v$session WHERE status='RUNNING') b ,
        (SELECT COUNT(*) recover FROM v$session WHERE status='SESS_RECOVERING') c;

	prompt
	prompt  ########6. system resource usage########
	prompt  ########  6.1 current cpu usage########
	!vmstat 1 5	  
	
	prompt
	prompt  ########  6.2 current memory usage########
 	set linesize 150
	set feedback off
	
	col "PGA (KB)"  format a15
	col "WPM (KB)"  format a15
	col "Status"  format a8
	
	select TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time"
					, "PGA" as "PGA (KB)"
--					, "WPM" as "WPM (KB)"
--					, CASE WHEN "PGA" < "WPM" then 'Good'
--           			ELSE 'Not Good'
--		       END as "Status"
	from ( select ROUND(sum(PGA_USED_MEM)/1024, 2) || ' K' as "PGA" 
			from v$process where NAME='WTHR') a
			, ( SELECT ROUND(value/1024, 2)  || ' K' as "WPM"
			FROM _vt_parameter WHERE name='EX_MEMORY_HARD_LIMIT') b ;

	prompt
prompt ########  6.3 WTHR count########
	!ps -ef | grep tbsvr | grep -v grep 
prompt
	!tbdown pid

	prompt
	prompt ########7. File system check########
	!df -k

	prompt
	prompt ########  7.1 home directory########
	!df -k $HOME

	prompt
	prompt ########  7.2 datafile directory########
	!df -k `cat $TB_HOME/config/$TB_SID.tip | grep DB_CREATE_FILE_DEST | cut -d'"' -f2 | cut -d'=' -f2`
	
	prompt
	prompt ########  7.3 archive log directory########
	!df -k `cat $TB_HOME/config/$TB_SID.tip | grep LOG_ARCHIVE_DEST | cut -d'"' -f2 | cut -d'=' -f2`

	prompt
	prompt ########8. Alert Log########
	prompt ########  8.1 callstack 발생 ########
	!find $TB_HOME/instance/$TB_SID/* -name "tbsvr.*" -print | xargs ls -alt


	prompt
	prompt ########9. ETC########
	prompt ########  9.1 CANT_EXTEND or OUT_OF_SHP 발생여부 ########
/* 전체 검색  */
--	!egrep -n 'ERROR_TX_CANT_ALLOC_EXT|ERROR_OUT_OF_SHP' $TB_HOME/instance/$TB_SID/log/tracelog/*
--로그파일 위치가 다를때 사용
--	!egrep -n 'ERROR_TX_CANT_ALLOC_EXT|ERROR_OUT_OF_SHP' `cat $TB_HOME/config/$TB_SID.tip | grep TRACE_LOG_DEST | cut -d'"' -f2 | cut -d'=' -f2`/*

/* 수정일이 60일 이내인 파일만 검색 */
	!find $TB_HOME/instance/$TB_SID/log/tracelog/* -type f -mtime -60 | xargs egrep -n 'ERROR_TX_CANT_ALLOC_EXT|ERROR_OUT_OF_SHP'
--로그파일 위치가 다를때 사용
--	!find `cat $TB_HOME/config/$TB_SID.tip | grep TRACE_LOG_DEST | cut -d'"' -f2 | cut -d'=' -f2`/* -type f -mtime -60 | xargs egrep -n 'ERROR_TX_CANT_ALLOC_EXT|ERROR_OUT_OF_SHP'

	prompt
	prompt ########  9.2 Blocking/Waiting Lock ########
	set feedback off
	set linesize 150
	
	col "Blocking User" format a15
	col "Waiting User" format a15
	col "Blocking Sid" format 999999999999
	col "Waiting Sid" format 99999999999
	col "Lock Type" format a12
	col "Holding mode" format a15
	col "Request mode" format a15
	col "SQL_ID" format 9999999
	
	SELECT bs.user_name "Blocking User"
	      ,ws.user_name "Waiting User"
	      ,bs.sess_id "Blocking Sid"
	      ,ws.sess_id "Waiting Sid"
	      ,wk.type "Lock Type"
	      ,DECODE(hk.lmode, 1, '[1]Row-S(S)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)' )  "Holding mode"
	      ,DECODE(wk.lmode, 1, '[1]Row-S(S)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)' )  "Request mode"
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
	  ORDER BY 1,3;

	prompt
	prompt ########  9.3 Current Lock Information ########
	col "User" format a15
	col "Sid" format 9999
	col "Object" format a35
	col "Status" format a8
	col "Lock_time" format a15
	
	SELECT s.sess_id  "Sid"
	      ,s.status "Status"
	      ,s.user_name "User"
	      ,o.owner|| '.' ||o.object_name "Object"
	      ,FLOOR(MOD((sysdate - vt.start_time)*24,24)) || ':'||
	        LPAD(FLOOR(MOD((sysdate - vt.start_time)*1440, 60)),2,0) ||':'||
	        LPAD(FLOOR(MOD((sysdate - vt.start_time)*86400,60)),2,0) AS "Lock_time"
	      ,DECODE(lmode, 1, '[1]Row-S(S)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)' )  "Lock mode"
	      ,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
	 FROM vt_wlock l, 
	      vt_session s,  
	      dba_objects o ,
	      vt_transaction vt
	WHERE l.type='WLOCK_DML'
	  AND l.thr_id = s.vtr_tid
	  AND l.id1 = o.object_id (+)
	  AND l.thr_id = vt.sess_id order by "Lock_time" DESC;

	prompt
	prompt ######## FINISHED ########
