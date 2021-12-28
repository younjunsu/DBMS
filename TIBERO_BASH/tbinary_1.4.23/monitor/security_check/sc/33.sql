set linesize 200
col grantee for a20
col role for a20
col admin_option for a15
col default_role for a15

select grantee, granted_role role from dba_role_privs;

!echo "====================="
!echo " Check"
!echo "====================="

set linesize 200
col grantee for a20
col owner for a20
col table_name for a20
col privilege for a20
col grantable for a10

select grantee, owner, table_name, privilege, grantable
from dba_tab_privs
where owner not in ('SYS','SYSGIS','SYSCAT')
and grantee not in (select grantee
                    from dba_role_privs
                    where granted_role='DBA')
and grantable='YES'
order by grantee;

