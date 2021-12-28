set linesize 200
col name for a30
col value for a30

select name,value/1024/1024/1024 GB from vt_parameter where name in ('TOTAL_SHM_SIZE','MEMORY_TARGET');

