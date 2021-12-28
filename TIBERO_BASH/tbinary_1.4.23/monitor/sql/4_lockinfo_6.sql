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
      --,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
      ,NVL(s.sql_id, s.prev_sql_id) || '/' || NVL2(s.sql_id, s.sql_child_number, s.prev_child_number) "SQL_ID"
 FROM vt_wlock l, 
      vt_session s,  
      dba_objects o ,
      vt_transaction vt
WHERE l.type='WLOCK_DML'
  AND l.sess_id = s.vtr_tid
  AND l.id1 = o.object_id (+)
  AND l.sess_id = vt.sess_id order by "Lock_time" DESC
/

exit

