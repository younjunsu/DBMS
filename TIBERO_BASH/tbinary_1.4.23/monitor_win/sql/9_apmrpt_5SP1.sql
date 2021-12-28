set serveroutput on;
set feedback off
set linesize 150
set pagesize 100

col instance_number for 99
col instance_name for a20
col startup_time for a20

accept begin_snap_id prompt 'Enter begin snapshots ID : '
accept end_snap_id prompt 'Enter end snapshots ID : '

DECLARE 
  begin_snap_id number;
  end_snap_id number;
  begin_date date;
  end_date date;
BEGIN
  select begin_interval_time into begin_date 
  from _apm_snapshot
  where snap_id = &begin_snap_id;
  
  select end_interval_time into end_date 
  from _apm_snapshot
  where snap_id = &end_snap_id;
   
  DBMS_OUTPUT.PUT_LINE(' ');
  DBMS_OUTPUT.PUT_LINE('Create APM Report : ' || to_char(begin_date,'YYYY-MM-DD HH24:MI:SS') || ' ~ ' || to_char(end_date,'YYYY-MM-DD HH24:MI:SS') );

  DBMS_APM.REPORT_TEXT(begin_date, end_date);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('APM Report create failed');
END;
/

exit
