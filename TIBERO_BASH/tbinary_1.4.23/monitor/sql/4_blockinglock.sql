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
  WHERE wk.status in( 'WAITER','CONVERTER')
    and hk.status = 'OWNER'
    and hk.lmode > decode(wk.status,'WAITER',1,0)
    and wk.type = hk.type
    and wk.id1 = hk.id1
    and wk.id2 = hk.id2
    and wk.thr_id = ws.vtr_tid
    and hk.thr_id = bs.vtr_tid
    and bs.sess_id != ws.sess_id
  ORDER BY 1,3
/

exit 

