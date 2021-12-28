set linesize 200
col username for a15
col profile for a20
col resource_name for a20
col limit for a30
col resource_name for a30
col username for a30


select * from dba_profiles where profile='DEFAULT';
