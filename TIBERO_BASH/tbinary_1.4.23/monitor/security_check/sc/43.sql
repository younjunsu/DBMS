set linesize 200
col owner for a20
col object_name for a35
col object_type for a15
select owner, object_name, object_type from dba_objects where object_name like '%AUDIT%' and object_type in ('TABLE','VIEW');
