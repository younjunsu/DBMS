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

exit
