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

exit

