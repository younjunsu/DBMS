set linesize 140
set pagesize 100
set feedback off

col tablespace_name format a15
col "Undoseg Activity" format a28


prompt 
prompt =================================
prompt =====   Undo Freespace    =======
prompt =================================

select  ts_name as "TABLESPACE_NAME",
        ROUND(total_size/1024/1024,2) as "TOTAL_SIZE(MB)",
        ROUND((total_size - free_size) / 1024/1024 ,2)as "USED_SIZE(MB)",
        ROUND(free_size/1024/1024,2) as "FREE_SIZE(MB)",
        ROUND(( free_size / total_size) * 100,2) as "FREE_SIZE(%)"
from v$undo_free_space
/

prompt 
prompt =================================
prompt =====   Undo Segment Info  =======
prompt =================================
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

prompt 
prompt =================================
prompt ===== Necessary Undo Size =======
prompt =================================
select d.name tablespace_name,
       d.undo_size/(1024*1024) "Current UNDO SIZE(MB)",
       SUBSTR(e.value,1,25) "UNDO RETENTION",
      ROUND((to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024),2) "Necessary UNDO SIZE(MB)"
from (
select ts#,name,(select  
                 sum(bytes) undo_size  from dba_data_files
where tablespace_name = name) undo_size
from v$tablespace
where type='UNDO'
) d,
v$parameters e,
v$parameters f,
(
select undo_tsno,max(undoblks/((end_time-begin_time)*3600*24)) "UNDO_BLOCK_PER_SEC"
FROM gv$undostat
group by undo_tsno
) g
where e.name = 'UNDO_RETENTION'
and f.name = 'DB_BLOCK_SIZE'
and d.ts# = g.undo_tsno(+)
/


exit