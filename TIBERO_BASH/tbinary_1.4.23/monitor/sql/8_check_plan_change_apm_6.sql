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
VAR BEFORE_SNAP_ID NUMBER;
VAR AFTER_SNAP_ID  NUMBER;
VAR V_SQL_TEXT     VARCHAR(2000);
--VAR V_MODULE       VARCHAR(2000);

ACCEPT BEFORE_SNAP_ID prompt 'INPUT BEFORE_SNAP_ID : '
ACCEPT AFTER_SNAP_ID  prompt 'INPUT AFTER_SNAP_ID  : '
ACCEPT V_SQL_TEXT    prompt 'INPUT V_SQL_TEXT (Included SQL Text OR Null is ALL) : '
--ACCEPT V_MODULE      prompt 'INPUT V_MODULE (Included Module Name OR Null is ALL) : '

EXEC :BEFORE_SNAP_ID  := &BEFORE_SNAP_ID;
EXEC :AFTER_SNAP_ID   := &AFTER_SNAP_ID;
EXEC :V_SQL_TEXT     := '%&V_SQL_TEXT%';
--EXEC :V_MODULE       := '%&V_MODULE%';

COL "(Before)SQL_HASH_VALUE/PLAN_HASH_VALUE" FOR A39
COL "(After)SQL_HASH_VALUE/PLAN_HASH_VALUE" FOR A39
COL MODULE FOR A20
COL SQL_TEXT FOR A50
COL HASH_SQL FOR A32
COL HASH_PLAN FOR A32
COL BEFORE_HASH_PLAN FOR A32
COL AFTER_HASH_PLAN FOR A32
SET LINESIZE 250


SELECT
        B.THREAD# B_THREAD, B.SQL_HASH_VALUE || '/' ||  B.PLAN_HASH_VALUE "(Before)SQL_HASH_VALUE/PLAN_HASH_VALUE"
       ,A.THREAD# A_THREAD, A.SQL_HASH_VALUE || '/' ||  A.PLAN_HASH_VALUE "(After)SQL_HASH_VALUE/PLAN_HASH_VALUE"
       ,CASE WHEN (B.HASH_PLAN=A.HASH_PLAN) THEN 'NOT CHANGED' ELSE 'CHANGED' END PLAN_CHANGED
       ,CASE WHEN (A.ELAPS_EXEC-B.ELAPS_EXEC) < 0 THEN 'EMPROVED' ELSE 'NOT EMPROVED' END  IMPROVEMENT
       ,B.ELAPS_EXEC/1000000 "BEFORE_ELAPS_EXEC(S)", A.ELAPS_EXEC/1000000 "AFTER_ELAPS_EXEC(S)"
       ,(A.ELAPS_EXEC-B.ELAPS_EXEC)/1000000 "ELAPS_GAP(S)"
       --,B.MODULE, SUBSTR(B.SQL_TEXT,1,50) SQL_TEXT
  FROM (
        SELECT f_hash_sql(T.sql_text) HASH_SQL
               ,f_hash_plan(T.SNAP_ID, S.THREAD#, S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE) HASH_PLAN
               ,S.THREAD# ,S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE, S.PARSE_CALLS, S.FETCHES, S.EXECUTIONS
               ,S.BUFFER_GETS, S.ELAPSED_TIME
               ,(CASE WHEN (S.EXECUTIONS > 0 )
                      THEN (S.ELAPSED_TIME/S.EXECUTIONS)
                      ELSE 0
                      END) ELAPS_EXEC
               ,S.ROWS_PROCESSED
               ,S.DISK_READ_TIME
               ,S.DISK_READS
               ,S.TEMP_SGMT_READ_TIME
               ,S.TEMP_SGMT_WRITE_TIME
               ,T.MODULE
               ,T.SQL_TEXT
          FROM SYS._TPR_SQLTEXT  T,
               SYS._TPR_SQLSTATS S
         WHERE 1 = 1
           AND S.THREAD#         = T.THREAD#
           AND S.SQL_HASH_VALUE  = T.SQL_HASH_VALUE
           AND S.PLAN_HASH_VALUE = T.PLAN_HASH_VALUE
           AND S.EXECUTIONS      > 0
           AND S.PLAN_HASH_VALUE > 0
           AND T.SQL_TEXT        NOT LIKE 'INSERT /*+ default_stat%'
           AND T.SQL_TEXT        NOT LIKE 'DELETE /*+ default_stat%'
           AND T.SQL_TEXT        NOT LIKE 'SELECT /*+ default_stat%'
           AND S.SNAP_ID         = :BEFORE_SNAP_ID
           AND T.MODULE          NOT IN ('DATAFILE OPEN','DML STAT FLUSH','JOB SCHD MAIN','JOB_SCHEDULER'
                                        ,'SECU LOGGING TO SYS TBL','TPM COLLECTOR','TPM SENDER','TPR SESSION'
                                        ,'TRIGGER','TX RECOVERY','UPDATE SESS LTIME','UPDATE USER STATUS')
           AND T.SQL_TEXT        LIKE :V_SQL_TEXT
           --AND T.MODULE          LIKE :V_MODULE
       ) B,
       (
        SELECT f_hash_sql(T.sql_text) HASH_SQL
               ,f_hash_plan(T.SNAP_ID, S.THREAD#, S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE) HASH_PLAN
               ,S.THREAD# ,S.SQL_HASH_VALUE, S.PLAN_HASH_VALUE, S.PARSE_CALLS, S.FETCHES, S.EXECUTIONS
               ,S.BUFFER_GETS, S.ELAPSED_TIME
               ,(CASE WHEN (S.EXECUTIONS > 0 )
                      THEN (S.ELAPSED_TIME/S.EXECUTIONS)
                      ELSE 0
                      END) ELAPS_EXEC
               ,S.ROWS_PROCESSED
               ,S.DISK_READ_TIME
               ,S.DISK_READS
               ,S.TEMP_SGMT_READ_TIME
               ,S.TEMP_SGMT_WRITE_TIME
               ,T.MODULE
               ,T.SQL_TEXT
          FROM SYS._TPR_SQLTEXT  T,
               SYS._TPR_SQLSTATS S
         WHERE 1 = 1
           AND S.THREAD#         = T.THREAD#
           AND S.SQL_HASH_VALUE  = T.SQL_HASH_VALUE
           AND S.PLAN_HASH_VALUE = T.PLAN_HASH_VALUE
           AND S.EXECUTIONS      > 0
           AND S.PLAN_HASH_VALUE > 0
           AND T.SQL_TEXT        NOT LIKE 'INSERT /*+ default_stat%'
           AND T.SQL_TEXT        NOT LIKE 'DELETE /*+ default_stat%'
           AND T.SQL_TEXT        NOT LIKE 'SELECT /*+ default_stat%'
           AND S.SNAP_ID         = :AFTER_SNAP_ID
           AND T.MODULE          NOT IN ('DATAFILE OPEN','DML STAT FLUSH','JOB SCHD MAIN','JOB_SCHEDULER'
                                        ,'SECU LOGGING TO SYS TBL','TPM COLLECTOR','TPM SENDER','TPR SESSION'
                                        ,'TRIGGER','TX RECOVERY','UPDATE SESS LTIME','UPDATE USER STATUS')
           AND T.SQL_TEXT        LIKE :V_SQL_TEXT
           --AND T.MODULE          LIKE :V_MODULE
       ) A
 WHERE B.HASH_SQL = A.HASH_SQL
 ORDER BY "ELAPS_GAP(S)" DESC
/




--drop function f_hash_sql;
--drop function f_hash_plan;

exit
