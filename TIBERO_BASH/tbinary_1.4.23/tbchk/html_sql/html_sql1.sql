select 
       '<!JB html>'||chr(10)||
       '<html>'||chr(10)||
       '<head>'||chr(10)||'<meta charset="euc-kr">'||chr(10)||
       '<title>TmaxData</title>'||chr(10)||
       '<style>'||chr(10)||'table { width: 100%; }'||chr(10)||'table, th, td {font-size: x-small; border: 1px solid #bcbcbc;}'||chr(10)||'</style>'||chr(10)||
       '</head>'||chr(10)||
       '<body><font size=1>'||chr(10)
from dual
union all
select
       '<h1>1. �������˴��</h1>'||chr(10)||
       '<table border="1">'||chr(10)||'<tbody>'||chr(10)||'<tr align="center">'||chr(10)||
       '<td bgcolor=#D8D7D7>PRODUCT</td>'||chr(10)||
       '<td>'||(select 'Tibero'||value from v$version where name = 'PRODUCT_MAJOR')||'</td>'||chr(10)||
       '<td bgcolor=#D8D7D7>VERSION</td>'||chr(10)||
       '<td colspan="3">'||(select value || ' ( '|| (select 'build '||value||' )'from v$version where name = 'BUILD_NUMBER') from v$version where name = 'STABLE_VERSION')||
       '</td>'||chr(10)||'</tr>'||chr(10)||
       '<tr align="center">'||chr(10)||
       '<td bgcolor=#D8D7D7>O/S</td>'||'<td>  </td>'||'<td bgcolor=#D8D7D7>HOSTNAME</td>'||'<td colspan="3">'||  
       (select HOST_NAME from v$instance)||'</td>'||chr(10)||'</tr>'||chr(10)||
       '<tr align="center">'||chr(10)||'<td bgcolor=#D8D7D7>TAC(Y/N)</td>'||chr(10)||'<td>'||
       (select decode(count(*),1,'N','Y') from gv$instance)||'</td>'||chr(10)||'<td bgcolor=#D8D7D7>MODE</td>'||chr(10)||'<td>'||
       (select log_mode from v$database)||'</td>'||chr(10)||'<td bgcolor=#D8D7D7>SID</td>'||chr(10)||'<td>'||
       (select NAME from v$database)||'</td>'||chr(10)||'</tr>'||chr(10)||'</tbody></table><br>'
from dual
union all
select
       '<h1>2. �������˰��</h1>'||chr(10)||
       '<table border="1">'||chr(10)||'<tbody>'||chr(10)||'<tr align="center">'||chr(10)||
       '<td width="180" bgcolor=#D8D7D7>���� ����</td><td width="180" bgcolor=#D8D7D7>����ġ</td><td bgcolor=#D8D7D7>���� ����</td></tr>'||chr(10)||
       '<tr><td colspan="3">1. TSM</td></tr>'||chr(10)||
       '<tr>'||chr(10)||'<td style="padding-left:10px">1.1 Shared memory size</td>'||chr(10)||'<td>TSM ����</td>'||chr(10)||
       '<td>'||(SELECT total/1024/1024 || ' M' FROM  v$sga WHERE  name = 'SHARED MEMORY')||'</td></tr>'||chr(10)||
       '<tr>'||chr(10)||'<td style="padding-left:10px">1.2 Shared pool size</td>'||chr(10)||'<td>Shared pool ����</td>'||chr(10)|| 
       '<td>'||(SELECT ROUND(total/1024/1024,0) || ' M' FROM v$sga  WHERE  name = 'SHARED POOL MEMORY')||'</td></tr>'||chr(10)||
       '<tr>'||chr(10)||'<td style="padding-left:10px">1.3 DB Cache size</td>'||chr(10)||'<td>DB Cache ����</td>'||chr(10)|| 
       '<td>'||(SELECT value/1024/1024 || ' M' FROM _vt_parameter WHERE name='DB_CACHE_SIZE')||'</td></tr>'||chr(10)||
       '<tr>'||chr(10)||'<td style="padding-left:10px">1.4 Log Buffer size</td>'||chr(10)||'<td>Log Buffer ����</td>'||chr(10)|| 
       '<td>'||(SELECT value/1024/1024 || ' M' FROM _vt_parameter WHERE name='LOG_BUFFER')||'</td></tr>'||chr(10)||
       '<tr><td colspan="3">2. DB performance</td></tr>'||chr(10)||
       '<tr>'||chr(10)||'<td style="padding-left:10px">2.1 Buffer Cache Hit Ratio</td>'||chr(10)||'<td>70% �̻�</td>'||chr(10)||
       '<td>'||
         (SELECT  ROUND( (1 - ( (pr1.value + pr2.value) / (bg1.value + bg2.value + bg3.value) ) ) * 100, 2) ||' %' 
         FROM v$sysstat pr1, v$sysstat pr2,
              v$sysstat bg1 , v$sysstat bg2 , v$sysstat bg3
         WHERE pr1.name = 'block disk read'
          and pr2.name = 'multi block disk read - blocks'
          and bg1.name = 'consistent block gets'
          and bg2.name = 'consistent multi gets - blocks'
          and bg3.name = 'current block gets')||'</td></tr>'
from dual
union all
select 
        '<tr>'||chr(10)||'<td style="padding-left:10px">2.2 SQL Cache Hit Ratio</td>'||chr(10)||'<td>90% �̻�</td>'||chr(10)||
        '<td>'||(SELECT GETHITRATIO || ' %' FROM v$librarycache where namespace = 'SQL AREA')||'</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">2.3 Dictionary Cache Hit Ratio</td>'||chr(10)||'<td>90% �̻�</td>'||chr(10)||
        '<td>'||(SELECT ROUND( ( sum(hit_cnt) - sum(miss_cnt) ) / sum(hit_cnt) * 100,1) ||' %' FROM v$rowcache)||'</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">2.4 Shared Cache Free Space</td>'||chr(10)||'<td>30% �̻�</td>'||chr(10)||
        '<td>'||
        (SELECT round((round((total - used)/1024/1024,1)/round(total/1024/1024,1))*100,2) ||' %'
         FROM v$sga WHERE name='SHARED POOL MEMORY' )||'</td></tr>'||chr(10)||
        '<tr><td colspan="3">3. space usage</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">3.1 Table space free space</td>'||chr(10)||'<td>20% �̻�</td>'||chr(10)||
        '<td>'||
        (
			select case when count(*) = 0 then '��� tablespace 20% �̻�'
			            else '20% ���� tablespace ('|| aggr_concat(TS_NAME, ',') ||')'
			       end
			from (
			        select 
			          ddf.tablespace_name as TS_NAME,
			          round( (1 - ( (ddf.bytes - dfs.bytes) / ddf.bytes) ) * 100, 2) "Free(%)"
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
			        where ddf.tablespace_name = dfs.tablespace_name)
			where "Free(%)" <= 20        
        ) ||'</td></tr>'
from dual
union all
select
        '<tr>'||chr(10)||'<td style="padding-left:10px">3.2 UNDO segment usage</td>'||chr(10)||'<td>"cannot extents" �߻� ����</td>'||chr(10)||
        '<td>'||
        (
			select case when count(*)=0 then '����'
			            else 'Ȯ�� �ʿ� , tablespace( '|| aggr_concat(TS_NAME, ',') ||')'
			       end
			from (
			        SELECT
			           tablespace_name TS_NAME, sum(vr.xacts) as g_xacts
			        FROM
			        dba_rollback_segs dr, v$rollstat vr,
			        (SELECT value FROM _vt_parameter WHERE name='DB_BLOCK_SIZE') pt
			        WHERE dr.segment_id=vr.usn group by tablespace_name)
			where g_xacts <> '0'
        ) ||'</td></tr>'||chr(10)||
        '<tr><td colspan="3">4. DISK I/O</td></tr>'||chr(10)||     
        '<tr>'||chr(10)||'<td style="padding-left:10px">4.1 FILE I/O contention</td>'||chr(10)||'<td>Ư�� DISK�� I/O ���� ����</td>'||chr(10)||   
        '<td>'||
        (
			select case when count(*) = 0 then '����'
			            else 'Ȯ�� �ʿ� , tablespace( '|| aggr_concat(TS_NAME, ',') ||' )'
			       end
			from (
			        SELECT  fl.tablespace_name TS_NAME, 
			                round(fs.AVGIOTIM/1000,3) AVG_TIME
			        FROM    V$DATAFILE df, V$FILESTAT fs, dba_data_files fl
			        WHERE   df.file# = fs.file# AND df.file# = fl.file_id )
			where AVG_TIME >= 0.005
        ) || '</td></tr>'
from dual
union all
select
        '<tr>'||chr(10)||'<td style="padding-left:10px">4.2 Online Redo Log switch Count</td>'||chr(10)||'<td>Ư�� �ð��� log switch ���� ����</td>'||'<td> </td></tr>'||chr(10)||
        '<tr><td colspan="3">5. Current session info</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">5.1 Current session Count</td>'||chr(10)||'<td>Total session count�� 80% ����</td>'||chr(10)||
        '<td>'||(
				  SELECT  'Total : '|| (a.acs + b.run) || ' / ' || 'Running : '|| b.run
				  FROM
				        (select wp.value * wt.value as max
				                from (select name, value from _VT_PARAMETER where name='WTHR_PROC_CNT' ) wp
				                , (select name, value from _VT_PARAMETER where name='_WTHR_PER_PROC') wt) m ,
				        (SELECT SUM(pga_used_mem) pga,
				        COUNT(*) acs  FROM v$session WHERE status='ACTIVE') a ,
				        (SELECT COUNT(*) run FROM v$session WHERE status='RUNNING') b ,
				        (SELECT COUNT(*) recover FROM v$session WHERE status='SESS_RECOVERING') c        
        ) ||'</td></tr>'
from dual
union all
select  
        '<tr><td colspan="3">6.System resource usage</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">6.1 Current cpu usage</td>'||chr(10)||'<td>30% ����</td><td></td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">6.2 Current memory usage</td>'||chr(10)||'<td>PGA ��뷮 < WPM</td>'||chr(10)||
        '<td>'||
        (
			select case when PGA_K < WPM_K then '���� ( '|| 'PGA : '||PGA_K||'K , WPM : '||WPM_K||'K )'
			            else '������( '|| 'PGA : '||PGA_K||'K , WPM : '||WPM_K||'K )'
			       end
			from (
			        select TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Current Time"
			                                        , "PGA" as PGA_K
			                                        , "WPM" as WPM_K
			                                      , CASE WHEN "PGA" < "WPM" then 'Good'
			                              ELSE 'Not Good'
			                     END as "Status"
			        from ( select ROUND(sum(PGA_USED_MEM)/1024, 2)  as "PGA"
			                 from v$session where TYPE='WTHR') a
			           , ( SELECT  round((to_number(vt.value) - s.total)/1024,0) AS WPM
			                 FROM v$sga s, _vt_parameter vt
			                WHERE vt.NAME = 'MEMORY_TARGET' AND s.name = 'SHARED MEMORY') b )
        )||'</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">6.3 WTHR count</td>'||chr(10)||'<td>WTHR_PROC_CNT ��ġ ����</td><td>'
from dual;
