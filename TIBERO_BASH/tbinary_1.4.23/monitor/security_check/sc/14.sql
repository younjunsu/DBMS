set linesize 200
col grantee for a20
col granted_role for a20
col admin_option for a15
col default_role for a15


select grantee, granted_role, admin_option from dba_role_privs where grantee not in ('SYS','OUTLN');

