set serveroutput on
set feedback off
set linesize 150
set pagesize 100

DECLARE
v_date varchar(20);
BEGIN
  DBMS_OUTPUT.PUT_LINE('====== TAC APM snapshot create. ===========');
  DBMS_OUTPUT.PUT_LINE( TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
  DBMS_APM.CREATE_SNAPSHOT_ALL();
  DBMS_OUTPUT.PUT_LINE('================================');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('TAC Snapshot create failed');
END;
/

exit
