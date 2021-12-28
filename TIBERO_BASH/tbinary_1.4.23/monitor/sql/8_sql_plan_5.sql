ACCEPT sql_id prompt 'INPUT SQL_ID : '

set linesize 150
set pagesize 120
set head off
set feed off
col "SQL Type" format a8
col "ID" format 99999
col "PLAN" format a100
col "SQL_TEXT" format a100
col "ROWS_PROCESSED" format 999999999


var sql_id number;
exec :sql_id := &sql_id;

prompt .----------------.
prompt | SQL TEXT       |
prompt +---------------------------------------------------------------------------------------------------
SELECT  sql_text "SQL_TEXT" 
FROM   v$sqltext  
WHERE sql_id = :sql_id
order by piece
/
set head on
prompt 
prompt .----------------.
prompt | SQL STAT       |
--prompt SQL_ID, PLAN_HASH_VALUE,EXECUTIONS Elapsed_Time GETS/EXECUTIONS MODULE ---------------------------------------------------------------------------------
prompt +---------------------------------------------------------------------------------------------------

select SQL_ID,
       PLAN_HASH_VALUE, 
       EXECUTIONS,
       ELAPSED_TIME/EXECUTIONS/1000000 "Elap/Exec(s)",
       BUFFER_GETS/EXECUTIONS "Gets/Exec",
	ROWS_PROCESSED "ROWS_PROCESSED",
       MODULE 
from v$sqlarea where sql_id = :sql_id
/

set head off

prompt ----------------------------------------------------------------------------------------------------
prompt .----------------.
prompt | Execution Plan |
prompt +---------------------------------------------------------------------------------------------------
select *
from
( 
SELECT 
      SUBSTRB(TO_CHAR(ID),1, 3) || LPAD(' ', LEVEL * 2) || UPPER(OPERATION) || 
      DECODE(OBJECT_NAME, NULL, NULL, ':' || OBJECT_NAME) || '(Cost:' || COST || ',%%CPU:' || 
      DECODE(COST, 0, 0, TRUNC( (COST - IO_COST) / COST * 100) ) || ',Rows:' || CARDINALITY || ')' || 
      DECODE(PSTART, '', '', '(PS:' || PSTART || ',PE:' || PEND || ')') AS "ExecutionPlan"   
FROM ( 
SELECT *
FROM V$SQL_PLAN
WHERE SQL_ID = :sql_id) 
START WITH DEPTH = 1 CONNECT BY PRIOR ID = PARENT_ID
    AND PRIOR SQL_ID = SQL_ID
  ORDER SIBLINGS BY POSITION
)
/
prompt .----------------.
prompt | Execution Stats |
prompt +-----------------------------------------------------------------------------------------
select *
from 
(
SELECT 
    SUBSTRB(TO_CHAR(ID), 1, 3) || 
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
                      WHERE SQL_ID = :sql_id ) I
               START WITH DEPTH = 1 
               CONNECT BY PRIOR ID = PARENT_ID AND PRIOR SQL_ID = SQL_ID 
               ORDER SIBLINGS BY POSITION) A, V$SQL_PLAN_STATISTICS S 
        WHERE A.SQL_ID = S.SQL_ID AND A.ID = S.ID)
)
/
set head off
prompt
prompt .------------------.
prompt | DBMS_XPLAN (ALL) |
prompt +-----------------------------------------------------------------------------------------
set lines 200
select * from table(dbms_xplan.display_cursor(:sql_id,'ALL'))
/

 
exit

