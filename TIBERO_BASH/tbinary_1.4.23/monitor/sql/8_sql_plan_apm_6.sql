set echo off
set feedback off
set verify off

var V_INPUT VARCHAR(20);
var V_SQL_HASH_VALUE number;
var V_PLAN_HASH_VALUE number;
--exec :B1 := 180074798;
--exec :B2 := 241648823;
ACCEPT V_INPUT PROMPT 'INPUT SQL_HASH_VALUE/PLAN_HASH_VALUE : '
exec :V_SQL_HASH_VALUE  := REGEXP_SUBSTR('&V_INPUT','[^/]+', 1, 1);
exec :V_PLAN_HASH_VALUE := REGEXP_SUBSTR('&V_INPUT','[^/]+', 1, 2);

set linesize 400
set pagesize 3000
col plan for a300


set head off
select sql_text
  from SYS._TPR_SQLTEXT
 where 1=1
   AND SQL_HASH_VALUE  = :V_SQL_HASH_VALUE 
   AND PLAN_HASH_VALUE = :V_PLAN_HASH_VALUE
/

set head on
select execs, row_cnt, (e_time/1000) elapsed, gets,
               lpad(to_char(pid), 4, ' ') as id,
               lpad(' ', (level - 1) * 2) || upper(operation) || decode(object_name, null, null, ': '||object_name) || ' (Cost:' || cost || ', %%CPU:' || decode(cost, 0, 0, trunc((cost - io_cost) / cost * 100)) || ', Rows:' || cardinality || ') ' || decode(pstart, '', '', '(PS:' || pstart || ', PE:' || pend || ')') AS plan
          from (select p.*, s.*,
                       p.id as pid, p.parent_id as ppid,
                       p.sql_hash_value as psql_hash_value,
                       p.plan_hash_value as pplan_hash_value
                  from sys._tpr_sql_plan p,
                       (select sum(dif_executions) execs,
                               sum(dif_output_rows) row_cnt,
                               sum(dif_elapsed_time) e_time,
                               sum(dif_cr_buffer_gets) gets,
                               sql_hash_value, plan_hash_value, id
                          from  sys._tpr_sql_plan_stat
                         group by sql_hash_value, plan_hash_value, id) s
         where p.sql_hash_value = :V_SQL_HASH_VALUE
           and p.plan_hash_value = :V_PLAN_HASH_VALUE
           and p.sql_hash_value = s.sql_hash_value(+)
           and p.plan_hash_value = s.plan_hash_value(+)
           and p.id = s.id(+))
         start with depth = 1
       connect by prior pid = ppid
           and prior psql_hash_value = psql_hash_value
           and prior pplan_hash_value = pplan_hash_value
         order siblings by position
/




--------"Predicate Information"

COL PREDICATE_INFORMATION FOR A150
 WITH X AS ( SELECT ID,
                    ACCESS_PREDICATES,
                    FILTER_PREDICATES
               FROM SYS._TPR_SQL_PLAN
              WHERE SQL_HASH_VALUE = :V_SQL_HASH_VALUE
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
FROM   SYS._TPR_SQL_PLAN
WHERE  SQL_HASH_VALUE = :V_SQL_HASH_VALUE
       AND OTHERS IS NOT NULL
       AND PLAN_HASH_VALUE = :V_PLAN_HASH_VALUE
       AND ( operation LIKE '%%table%%'
              OR operation LIKE '%%index%%'
              OR OTHERS LIKE '%%outline%%' );
			  
		 

quit

