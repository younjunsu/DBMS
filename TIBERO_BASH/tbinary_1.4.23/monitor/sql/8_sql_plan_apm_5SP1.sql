set echo off
set feedback off
set verify off

-- CREATE FUNCTION "F_SQL"
CREATE OR REPLACE FUNCTION F_SQL(  V_HASH_VALUE NUMBER
                                  ,V_SQL_ID     NUMBER )
RETURN CLOB IS
        V_CUR    SYS_REFCURSOR;
        V_QUERY  VARCHAR2(500);
        V_LINE   SYS._APM_SQLTEXT.SQL_TEXT%TYPE;
        V_TOTAL  CLOB;
BEGIN
        V_QUERY :=
-------------------------------------------------------------------
'SELECT
       T.SQL_TEXT
  FROM SYS._APM_SQLTEXT  T
 WHERE 1 = 1
   AND (T.SQL_ID, T.HASH_VALUE)IN(SELECT S.SQL_ID
                                        ,S.PLAN_HASH_VALUE
                                   FROM SYS._APM_SQLSTATS S) 
   AND T.HASH_VALUE = ?
   AND T.SQL_ID     = ?
 ORDER BY PIECE'
;
-------------------------------------------------------------------

            OPEN V_CUR FOR V_QUERY USING V_HASH_VALUE, V_SQL_ID;
           LOOP
              FETCH V_CUR INTO V_LINE;
              EXIT WHEN V_CUR%NOTFOUND;

              V_TOTAL := V_TOTAL || V_LINE;
           END LOOP;
        CLOSE V_CUR;
    RETURN V_TOTAL;
END;
/


var V_INPUT VARCHAR(20);
var V_SQL_ID number;
var V_PLAN_HASH_VALUE number;
--exec :B1 := 180074798;
--exec :B2 := 241648823;
ACCEPT V_INPUT PROMPT 'INPUT SQL_ID/PLAN_HASH_VALUE : '
exec :V_SQL_ID          := REGEXP_SUBSTR('&V_INPUT','[^/]+', 1, 1);
exec :V_PLAN_HASH_VALUE := REGEXP_SUBSTR('&V_INPUT','[^/]+', 1, 2);

set long 2000000000
set linesize 400
set pagesize 3000
col plan for a300


set head off
-- SQL TEXT
SELECT F_SQL(:V_PLAN_HASH_VALUE,:V_SQL_ID) FROM DUAL;
set head on

-- SQL PLAN, STAT
select  execs
       ,row_cnt
       ,(e_time/1000) elapsed
       ,gets
       ,lpad(to_char(pid), 4, ' ') as id
       ,lpad(' ', (level - 1) * 2) || upper(operation) || decode(object_name, null, null, ': '||object_name) 
        || ' (Cost:' || cost || ', %%CPU:' || decode(cost, 0, 0, trunc((cost - io_cost) / cost * 100)) 
        || ', Rows:' || cardinality || ') ' || decode(pstart, '', '', '(PS:' || pstart || ', PE:' || pend || ')') AS plan
  from (
        select  p.*
               ,s.*
               ,p.id              as pid
               ,p.parent_id       as ppid
               ,p.sql_id          as psql_id
               ,p.plan_hash_value as pplan_hash_value
          from  sys._apm_sql_plan p,
               (
                select  sum(dif_executions)     execs
                       ,sum(dif_output_rows)    row_cnt
                       ,sum(dif_elapsed_time)   e_time
                       ,sum(dif_cr_buffer_gets) gets
                       ,sql_id
                       ,plan_hash_value 
                       ,id
                  from  sys._apm_sql_plan_stat
                 group by  sql_id
                          ,plan_hash_value
                          ,id
               ) s
         where p.sql_id          = :V_SQL_ID
           and p.plan_hash_value = :V_PLAN_HASH_VALUE
           and p.sql_id          = s.sql_id(+)
           and p.plan_hash_value = s.plan_hash_value(+)
           and p.id = s.id(+)
        )
 start with depth = 1
 connect by prior pid              = ppid
        and prior psql_id          = psql_id
        and prior pplan_hash_value = pplan_hash_value
 order siblings by position
/




--------"Predicate Information"

COL PREDICATE_INFORMATION FOR A150
 WITH X AS ( SELECT ID,
                    ACCESS_PREDICATES,
                    FILTER_PREDICATES
               FROM SYS._APM_SQL_PLAN
              WHERE SQL_ID = :V_SQL_ID
		AND PLAN_HASH_VALUE = :V_PLAN_HASH_VALUE
                AND (FILTER_PREDICATES IS NOT NULL OR ACCESS_PREDICATES IS NOT NULL ) 
            ) 
 SELECT PRED AS "PREDICATE_INFORMATION"
   FROM ( SELECT ID,
                 LPAD(TO_CHAR(ID),
                 4,
                 ' ') || ' - filter: ' || FILTER_PREDICATES AS PRED
            FROM X
           WHERE FILTER_PREDICATES IS NOT NULL
           UNION
          SELECT ID,
                 LPAD(TO_CHAR(ID),
                 4,
                 ' ') || ' - access: ' || ACCESS_PREDICATES AS PRED
            FROM X
           WHERE ACCESS_PREDICATES IS NOT NULL )
  ORDER BY ID;

 


--------"Note"
SELECT Lpad(To_char(id), 4, ' ')
       || ' - '
       || OTHERS AS "Note"
FROM   SYS._APM_SQL_PLAN
WHERE  SQL_ID = :V_SQL_ID
       AND OTHERS IS NOT NULL
       AND PLAN_HASH_VALUE = :V_PLAN_HASH_VALUE
       AND (     operation LIKE '%%table%%'
              OR operation LIKE '%%index%%'
              OR OTHERS    LIKE '%%outline%%' );
			  
		 
--drop function f_sql;

quit

