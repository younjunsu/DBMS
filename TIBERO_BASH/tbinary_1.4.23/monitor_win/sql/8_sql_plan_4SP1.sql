ACCEPT sql_id prompt 'INPUT SQL_ID : '

set linesize 132
set pagesize 100

col "SQL Type" format a8
col "ID" format 99999
col "PLAN" format a100

SELECT DECODE(command_type,1 ,'SELECT', 2 ,'INSERT', 3, 'UPDATE', 4 , 'DELETE' , 5, 'CALL', 0) "SQL Type",
       0 "ID",
       0 parent_id,
       sql_text "PLAN" 
FROM   v$sqltext  
WHERE sql_id = &sql_id
UNION ALL
SELECT  NULL, 0, NULL, '.----------------.' FROM dual
UNION ALL
SELECT  NULL, 0, NULL, '| Execution Plan |' FROM dual
UNION ALL
SELECT  NULL, 0, NULL, '+-----------------------------------------------------------------------------------------' FROM dual
UNION ALL
SELECT '' "SQL Type" ,
       id,
       parent_id,
       LPAD(' ', 2*(depth))
            ||operation
            ||case when object# is NULL 
                   then '' 
                   else ' of ['||(SELECT object_name FROM dba_objects WHERE object_id = object# and rownum =1)||' (obj#='||object# ||')]' end
            ||decode(cost,NULL,'','(Cost='||cost||') '||decode(cardinality, NULL,'','(Card='||CARDINALITY||')')
           ) "PLAN"
FROM   v$sql_plan
WHERE sql_id = &sql_id
/
 
exit

