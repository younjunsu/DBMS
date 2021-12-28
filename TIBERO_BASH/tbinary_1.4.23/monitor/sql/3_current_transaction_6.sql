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
 ,'[' || nvl(vs.sql_id,vs.prev_sql_id) || '/' || NVL2(vs.sql_id, vs.sql_child_number, vs.prev_child_number) ||'] '|| vst.sql_text "SQL_ID"
FROM
  v$session vs,
  v$transaction vt,
  (select * from v$sqltext where piece=0) vst,
  v$access va
WHERE
     vt.sess_id = vs.sid
 and vt.sess_id = va.sid
 and nvl(vs.sql_id,vs.prev_sql_id) = vst.sql_id(+)
 and nvl2(vs.sql_id, vs.sql_child_number, vs.prev_child_number) = vst.child_number(+)
ORDER BY "Time", "SID" , "User" DESC
/

exit

