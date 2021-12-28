set linesize 132
set pagesize 120
SET VERIFY OFF
set feed off

col "SQL Type" format a8
col "ID" format 99999
col "PLAN" format a100

ACCEPT sql_id prompt 'INPUT SQL_ID(ex: sql_id/sql_child_number ) : '

var sql_id varchar(13);
var sql_child_number number;
exec :sql_id := REGEXP_SUBSTR('&sql_id','[^/]+', 1, 1)
exec :sql_child_number := REGEXP_SUBSTR('&sql_id','[^/]+', 1, 2)

prompt ## SQL Info
prompt ----------------------------------------------------------------------------------------------------
select sql_id, child_number, hash_value, plan_hash_value
      ,decode(EXECUTIONS, 0, -1, round(BUFFER_GETS/EXECUTIONS,3)) "Gets/Exec"
      ,decode(EXECUTIONS, 0, -1, round(ELAPSED_TIME/EXECUTIONS/1000,3)) as "Elap/Exec(ms)"
      ,executions
from v$sql
where sql_id = :sql_id and child_number = :sql_child_number
/

set head off
prompt ## SQL TEXT
prompt ----------------------------------------------------------------------------------------------------
SELECT sql_text "PLAN" 
FROM   v$sqltext_with_newlines
WHERE sql_id = :sql_id and child_number = :sql_child_number
UNION ALL
SELECT  '.----------------.' FROM dual
UNION ALL
SELECT  '| Execution Plan |' FROM dual
UNION ALL
SELECT '+-----------------------------------------------------------------------------------------' FROM dual
union all
select *
from
( 
SELECT SUBSTRB(TO_CHAR(ID),1, 3) || LPAD(' ', LEVEL * 2) || UPPER(OPERATION) || 
      DECODE(OBJECT_NAME, NULL, NULL, ':' || OBJECT_NAME) || '(Cost:' || COST || ',%%CPU:' || 
      DECODE(COST, 0, 0, TRUNC( (COST - IO_COST) / COST * 100) ) || ',Card:' || CARDINALITY || ')' || 
      DECODE(PSTART, '', '', '(PS:' || PSTART || ',PE:' || PEND || ')') AS "ExecutionPlan"   
FROM ( 
SELECT *
FROM V$SQL_PLAN
WHERE SQL_ID = :sql_id  and child_number = :sql_child_number) 
START WITH DEPTH = 1 CONNECT BY PRIOR ID = PARENT_ID
    AND PRIOR SQL_ID = SQL_ID AND PRIOR CHILD_NUMBER = CHILD_NUMBER
  ORDER SIBLINGS BY POSITION
)
union all
SELECT  '+-----------------------------------------------------------------------------------------' FROM dual
union all
SELECT  '| Execution Stats |' FROM dual
UNION ALL
SELECT  '+-----------------------------------------------------------------------------------------' FROM dual
union all
select *
from 
(
SELECT SUBSTRB(TO_CHAR(ID), 1, 3) || 
    LPAD(' ', L * 2) || UPPER(OPERATION) || 
    DECODE(OBJECT_NAME, NULL, NULL, ': '||OBJECT_NAME) || 
    ' (Time:' || TO_CHAR(LAST_ELAPSED_TIME, 'FM9999999.99') || 
    ' ms, Rows:' || LAST_OUTPUT_ROWS || 
    ', Starts:' || LAST_STARTS || ') ' AS "Execution Stat"
FROM (SELECT A.ID, A.OPERATION, A.OBJECT_NAME, A.COST, 
             A.IO_COST, A.CARDINALITY, A.PSTART, A.PEND, 
             S.LAST_ELAPSED_TIME, S.LAST_OUTPUT_ROWS, S.LAST_STARTS, A.L 
        FROM (SELECT I.*, LEVEL L 
               FROM (SELECT * FROM V$SQL_PLAN 
                      WHERE SQL_ID = :sql_id and child_number = :sql_child_number) I
               START WITH DEPTH = 1 
               CONNECT BY PRIOR ID = PARENT_ID AND PRIOR SQL_ID = SQL_ID AND PRIOR CHILD_NUMBER = CHILD_NUMBER 
               ORDER SIBLINGS BY POSITION) A, V$SQL_PLAN_STATISTICS S 
        WHERE A.SQL_ID = S.SQL_ID AND A.CHILD_NUMBER=S.CHILD_NUMBER AND A.ID = S.ID)
)
/

prompt
prompt .------------------.
prompt | DBMS_XPLAN (ALL) |
prompt +-----------------------------------------------------------------------------------------
set lines 200
select * from table(dbms_xplan.display_cursor(:sql_id, :sql_child_number, 'ALL'))
/

 
exit
