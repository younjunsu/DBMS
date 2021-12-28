SET ECHO OFF
set feedback off
set verify off


-- CREATE HASH FUNCTION "F_HASH_SQL"
CREATE OR REPLACE FUNCTION F_HASH_SQL(v_varchar2 varchar2)
RETURN VARCHAR2 IS
v_result varchar2(100);
BEGIN
v_result := DBMS_CRYPTO.HASH(TO_CLOB(v_varchar2),1);
RETURN v_result;
END;
/


-- CREATE HASH FUNCTION "F_HASH_PLAN"
CREATE OR REPLACE FUNCTION F_HASH_PLAN(  V_SNAP_ID         NUMBER
                                        ,V_THREAD          NUMBER
                                        ,V_SQL_HASH_VALUE  NUMBER
                                        ,V_PLAN_HASH_VALUE NUMBER )
RETURN VARCHAR2 IS
        V_CUR    SYS_REFCURSOR;
        V_QUERY  VARCHAR2(500);
        V_LINE   VARCHAR2(200);
        V_TOTAL  CLOB;
BEGIN
        V_QUERY :=
-------------------------------------------------------------------
'SELECT
        SUBSTR(TO_CHAR(ID),1, 5) || UPPER(OPERATION)
             || DECODE(OBJECT_NAME, NULL, NULL, OBJECT_NAME)
   FROM SYS._TPR_SQL_PLAN
  WHERE 1 = 1
    AND SNAP_ID         = ?
    AND THREAD#         = ?
    AND SQL_HASH_VALUE  = ?
    AND PLAN_HASH_VALUE = ?
    AND ID <> 0
   START WITH DEPTH = 1
   CONNECT BY PRIOR ID              = PARENT_ID
          AND PRIOR SQL_HASH_VALUE  = SQL_HASH_VALUE
          AND PRIOR PLAN_HASH_VALUE = PLAN_HASH_VALUE
  ORDER  SIBLINGS BY POSITION'
;
-------------------------------------------------------------------

            OPEN V_CUR FOR V_QUERY USING V_SNAP_ID, V_THREAD, V_SQL_HASH_VALUE, V_PLAN_HASH_VALUE;
           LOOP
              FETCH V_CUR INTO V_LINE;
              EXIT WHEN V_CUR%NOTFOUND;

              V_TOTAL := V_TOTAL || V_LINE || CHR(13) || CHR(10);
           END LOOP;
        CLOSE V_CUR;

    RETURN DBMS_CRYPTO.HASH(V_TOTAL,1);
END;
/



-- ANALYSIS SNAPSHOT
VAR START_SNAP_ID NUMBER;
VAR END_SNAP_ID   NUMBER;
VAR V_SQL_TEXT    VARCHAR(2000);
--VAR V_MODULE      VARCHAR(2000);

ACCEPT START_SNAP_ID prompt 'INPUT START_SNAP_ID : '
ACCEPT END_SNAP_ID   prompt 'INPUT END_SNAP_ID  : '
ACCEPT V_SQL_TEXT    prompt 'INPUT V_SQL_TEXT (Included SQL Text OR Null is ALL) : '
--ACCEPT V_MODULE      prompt 'INPUT V_MODULE (Included Module Name OR Null is ALL) : '

EXEC :START_SNAP_ID  := &START_SNAP_ID;
EXEC :END_SNAP_ID    := &END_SNAP_ID;
EXEC :V_SQL_TEXT     := '%&V_SQL_TEXT%';
--EXEC :V_MODULE       := '%&V_MODULE%';


COL "SQL_HASH_VALUE/PLAN_HASH_VALUE" FOR A30
COL MODULE FOR A20
COL SQL_TEXT FOR A100
COL HASH_SQL FOR A32
COL HASH_PLAN FOR A32
SET LINESIZE 250


SELECT  Y.SQL_HASH_VALUE || '/' || Y.PLAN_HASH_VALUE "SQL_HASH_VALUE/PLAN_HASH_VALUE"
       ,Y.SQL_TEXT
  FROM
    (
     SELECT  HASH_SQL
            ,HASH_PLAN
            ,CNT_TOTAL
       FROM (
		     SELECT  HASH_SQL
		            ,HASH_PLAN
		            ,COUNT(HASH_SQL) OVER(PARTITION BY HASH_SQL) CNT_TOTAL
		      FROM (
		           SELECT
		                   F_HASH_SQL(T.SQL_TEXT) HASH_SQL
		                  ,F_HASH_PLAN(T.SNAP_ID, S.THREAD#, S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE) HASH_PLAN
		             FROM  SYS._TPR_SQLTEXT  T
		                  ,SYS._TPR_SQLSTATS S
		            WHERE 1 = 1
		              AND S.THREAD#         = T.THREAD#
                              AND S.SQL_HASH_VALUE  = T.SQL_HASH_VALUE
		              AND S.PLAN_HASH_VALUE = T.PLAN_HASH_VALUE
		              AND S.EXECUTIONS      > 0
		              AND S.PLAN_HASH_VALUE > 0
		              AND T.SQL_TEXT        NOT LIKE 'insert /*+ default_stat%'
		              AND T.SQL_TEXT        NOT LIKE 'delete /*+ default_stat%'
		              AND T.SQL_TEXT        NOT LIKE 'select /*+ default_stat%'
		              AND S.SNAP_ID         >= :START_SNAP_ID
		              AND S.SNAP_ID         <= :END_SNAP_ID
                              AND T.MODULE          NOT IN ('DATAFILE OPEN','DML STAT FLUSH','JOB SCHD MAIN','JOB_SCHEDULER'
                                                           ,'SECU LOGGING TO SYS TBL','TPM COLLECTOR','TPM SENDER','TPR SESSION'
                                                           ,'TRIGGER','TX RECOVERY','UPDATE SESS LTIME','UPDATE USER STATUS')
                              AND T.SQL_TEXT        LIKE :V_SQL_TEXT
                              --AND T.MODULE          LIKE :V_MODULE

		           )
		     GROUP BY HASH_SQL, HASH_PLAN
		     )
	  WHERE CNT_TOTAL > 1
     ) x
     ,(
       SELECT
               ROW_NUMBER() OVER(PARTITION BY T.HASH_SQL, T.HASH_PLAN ORDER BY T.HASH_PLAN) ROW_NUM
              ,T.*
         FROM (
           SELECT
                   F_HASH_SQL(T.SQL_TEXT) HASH_SQL
                  ,F_HASH_PLAN(T.SNAP_ID, S.THREAD#, S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE) HASH_PLAN
                  ,S.SNAP_ID
                  ,S.THREAD#
                  ,S.SQL_HASH_VALUE
                  ,S.PLAN_HASH_VALUE
                  ,T.SQL_TEXT
             FROM  SYS._TPR_SQLTEXT  T
                  ,SYS._TPR_SQLSTATS S
            WHERE 1 = 1
              AND S.THREAD#         = T.THREAD#
              AND S.SQL_HASH_VALUE  = T.SQL_HASH_VALUE
              AND S.PLAN_HASH_VALUE = T.PLAN_HASH_VALUE
              AND S.EXECUTIONS      > 0
              AND S.PLAN_HASH_VALUE > 0
              AND T.SQL_TEXT        NOT LIKE 'insert /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'delete /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'select /*+ default_stat%'
              AND S.SNAP_ID         >= :START_SNAP_ID
              AND S.SNAP_ID         <= :END_SNAP_ID
              AND T.MODULE          NOT IN ('DATAFILE OPEN','DML STAT FLUSH','JOB SCHD MAIN','JOB_SCHEDULER'
                                            ,'SECU LOGGING TO SYS TBL','TPM COLLECTOR','TPM SENDER','TPR SESSION'
                                            ,'TRIGGER','TX RECOVERY','UPDATE SESS LTIME','UPDATE USER STATUS')
              AND T.SQL_TEXT        LIKE :V_SQL_TEXT
              --AND T.MODULE          LIKE :V_MODULE
            ) T
           ) Y
WHERE Y.HASH_SQL  = X.HASH_SQL
  AND Y.HASH_PLAN = X.HASH_PLAN
  AND Y.ROW_NUM = 1
ORDER BY Y.HASH_SQL, Y.HASH_PLAN, Y.SNAP_ID
/



--drop function f_hash_sql;
--drop function f_hash_plan;

exit
