SET ECHO OFF
set feedback off
set verify off


-- CREATE HASH FUNCTION "F_HASH_SQL"
CREATE OR REPLACE FUNCTION F_HASH_SQL(  V_SNAP_ID    NUMBER
                                       ,V_THREAD     NUMBER
                                       ,V_HASH_VALUE NUMBER
                                       ,V_SQL_ID     NUMBER )
RETURN VARCHAR2 IS
        V_CUR    SYS_REFCURSOR;
        V_QUERY  VARCHAR2(500);
        V_LINE   SYS._APM_SQLTEXT.SQL_TEXT%TYPE;
        V_TOTAL  CLOB;
BEGIN
        V_QUERY :=
-------------------------------------------------------------------
'SELECT
       SQL_TEXT
  FROM SYS._APM_SQLTEXT
 WHERE 1 = 1
   AND SNAP_ID    = ?
   AND THREAD#    = ?
   AND HASH_VALUE = ?
   AND SQL_ID     = ?
 ORDER BY PIECE'
;
-------------------------------------------------------------------

	    OPEN V_CUR FOR V_QUERY USING V_SNAP_ID, V_THREAD, V_HASH_VALUE, V_SQL_ID;
           LOOP
              FETCH V_CUR INTO V_LINE;
              EXIT WHEN V_CUR%NOTFOUND;

              V_TOTAL := V_TOTAL || V_LINE|| CHR(13) || CHR(10);
           END LOOP;
        CLOSE V_CUR;
    RETURN DBMS_CRYPTO.HASH(V_TOTAL,1);
END;
/


-- CREATE HASH FUNCTION "F_HASH_PLAN"
CREATE OR REPLACE FUNCTION F_HASH_PLAN(  V_SNAP_ID         NUMBER
                                        ,V_THREAD          NUMBER
                                        ,V_PLAN_HASH_VALUE NUMBER
                                        ,V_SQL_ID          NUMBER )
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
   FROM SYS._APM_SQL_PLAN
  WHERE 1 = 1
    AND SNAP_ID         = ?
    AND THREAD#         = ?
    AND PLAN_HASH_VALUE = ?
    AND SQL_ID          = ?
    AND ID <> 0
   START WITH DEPTH = 1
   CONNECT BY PRIOR ID              = PARENT_ID
          AND PRIOR SQL_ID          = SQL_ID
          AND PRIOR PLAN_HASH_VALUE = PLAN_HASH_VALUE
  ORDER  SIBLINGS BY POSITION'
;
-------------------------------------------------------------------

	    OPEN V_CUR FOR V_QUERY USING V_SNAP_ID, V_THREAD, V_PLAN_HASH_VALUE, V_SQL_ID;
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

ACCEPT BEFORE_SNAP_ID prompt 'INPUT BEFORE_SNAP_ID : '
ACCEPT AFTER_SNAP_ID  prompt 'INPUT AFTER_SNAP_ID  : '
ACCEPT V_SQL_TEXT     prompt 'INPUT V_SQL_TEXT (Included SQL Text OR Null is ALL) : '

EXEC :BEFORE_SNAP_ID  := &BEFORE_SNAP_ID;
EXEC :AFTER_SNAP_ID   := &AFTER_SNAP_ID;
EXEC :V_SQL_TEXT      := '%&V_SQL_TEXT%';


COL "(Before)SQL_ID/PLAN_HASH_VALUE" FOR A30
COL "(After)SQL_ID/PLAN_HASH_VALUE" FOR A30
COL MODULE FOR A20
COL SQL_TEXT FOR A50
COL HASH_SQL FOR A32
COL HASH_PLAN FOR A32
COL BEFORE_HASH_PLAN FOR A32
COL AFTER_HASH_PLAN FOR A32
SET LINESIZE 250


SELECT
       B.THREAD# B_THREAD, B.SQL_ID || '/' || B.PLAN_HASH_VALUE "(Before)SQL_ID/PLAN_HASH_VALUE"
      ,A.THREAD# A_THREAD, A.SQL_ID || '/' || A.PLAN_HASH_VALUE "(After)SQL_ID/PLAN_HASH_VALUE"
      ,CASE WHEN (B.HASH_PLAN=A.HASH_PLAN) THEN 'NOT CHANGED' ELSE 'CHANGED' END PLAN_CHANGED
      ,CASE WHEN (A.ELAPS_EXEC-B.ELAPS_EXEC) < 0 THEN 'EMPROVED' ELSE 'NOT EMPROVED' END  IMPROVEMENT
      ,B.ELAPS_EXEC/1000000 "BEFORE_ELAPS_EXEC(S)", A.ELAPS_EXEC/1000000 "AFTER_ELAPS_EXEC(S)"
      ,(A.ELAPS_EXEC-B.ELAPS_EXEC)/1000000 "ELAPS_GAP(S)"
      --,B.SQL_TEXT
  FROM (
           SELECT
                   F_HASH_SQL(T.SNAP_ID, T.THREAD#, T.HASH_VALUE, T.SQL_ID) HASH_SQL
                  ,F_HASH_PLAN(T.SNAP_ID, S.THREAD#, S.PLAN_HASH_VALUE, S.SQL_ID) HASH_PLAN
                  ,S.THREAD#, S.SQL_ID, S.PLAN_HASH_VALUE, S.PARSE_CALLS, S.FETCHES,S.EXECUTIONS
                  ,S.BUFFER_GETS, S.ELAPSED_TIME
                  ,(CASE WHEN (S.EXECUTIONS > 0 )
                         THEN (S.ELAPSED_TIME/S.EXECUTIONS)
                         ELSE 0
                    END) ELAPS_EXEC
                  ,S.ROWS_PROCESSED
                  ,S.DISK_READ_TIME
                  ,S.TEMP_SGMT_READ_TIME
                  ,S.TEMP_SGMT_WRITE_TIME
                  ,T.SQL_TEXT
             FROM  SYS._APM_SQLTEXT  T
                  ,SYS._APM_SQLSTATS S
            WHERE 1 = 1
              AND S.THREAD#         = T.THREAD#
              AND S.SQL_ID          = T.SQL_ID
              AND S.PLAN_HASH_VALUE = T.HASH_VALUE
              AND S.EXECUTIONS      > 0
              AND S.PLAN_HASH_VALUE > 0
              AND T.SQL_TEXT        NOT LIKE 'insert /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'delete /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'select /*+ default_stat%'
              AND S.SNAP_ID         = :BEFORE_SNAP_ID
              AND T.SQL_TEXT        LIKE :V_SQL_TEXT
              AND T.PIECE           = 0
           ) B
         ,(
           SELECT
                   F_HASH_SQL(T.SNAP_ID, T.THREAD#, T.HASH_VALUE, T.SQL_ID) HASH_SQL
                  ,F_HASH_PLAN(T.SNAP_ID, S.THREAD#, S.PLAN_HASH_VALUE, S.SQL_ID) HASH_PLAN
                  ,S.THREAD#, S.SQL_ID, S.PLAN_HASH_VALUE, S.PARSE_CALLS, S.FETCHES, S.EXECUTIONS
                  ,S.BUFFER_GETS, S.ELAPSED_TIME
                  ,(CASE WHEN (S.EXECUTIONS > 0 )
                         THEN (S.ELAPSED_TIME/S.EXECUTIONS)
                         ELSE 0
                    END) ELAPS_EXEC
                  ,S.ROWS_PROCESSED
                  ,S.DISK_READ_TIME
                  ,S.TEMP_SGMT_READ_TIME
                  ,S.TEMP_SGMT_WRITE_TIME
                  ,T.SQL_TEXT
             FROM  SYS._APM_SQLTEXT  T
                  ,SYS._APM_SQLSTATS S
            WHERE 1 = 1
              AND S.THREAD#         = T.THREAD#
              AND S.SQL_ID          = T.SQL_ID
              AND S.PLAN_HASH_VALUE = T.HASH_VALUE
              AND S.EXECUTIONS      > 0
              AND S.PLAN_HASH_VALUE > 0
              AND T.SQL_TEXT        NOT LIKE 'insert /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'delete /*+ default_stat%'
              AND T.SQL_TEXT        NOT LIKE 'select /*+ default_stat%'
              AND S.SNAP_ID         = :AFTER_SNAP_ID
              AND T.SQL_TEXT        LIKE :V_SQL_TEXT
              AND T.PIECE           = 0
           ) A
 WHERE B.HASH_SQL = A.HASH_SQL
 ORDER BY "ELAPS_GAP(S)" DESC
/


--drop function f_hash_sql;
--drop function f_hash_plan;

exit
