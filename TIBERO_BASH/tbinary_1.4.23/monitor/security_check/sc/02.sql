col username for a30
set linesize 200; 
set pagesize 500
     col profile for a15
     col resource_name for a30
     col limit for a20

select a.username, dba.profile from all_users as a, dba_users as dba where a.username=dba.username;

