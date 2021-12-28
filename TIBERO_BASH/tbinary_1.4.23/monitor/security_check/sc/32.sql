set linesize 200
col grantee for a20
col granted_role for a20
col admin_option for a15
col default_role for a15

select grantee, granted_role from dba_role_privs where grantee not in ('SYS','OUTLN');


set pagesize 500
set linesize 200
col owner for a20
col object_type for a30
col count(*) for 9999999
select owner,object_type,count(*) from dba_objects group by owner,object_type
having owner not in ('SYS','SYSCAT','OUTLN','PUBLIC','SYSGIS');
