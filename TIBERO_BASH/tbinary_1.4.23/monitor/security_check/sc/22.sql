set linesize 300
col grantee for a20
col privilege for a20
col owner for a20
col table_name for a30
select grantee, privilege, owner, table_name
from dba_tab_privs 
where (owner='SYS' or table_name like 'DBA%') 
	and privilege != 'EXECUTE' 
	and grantee not in ('HS_ADMIN_ROLE','PUBLIC', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'AURORAŠJIS$UTILI TY$', 'OSE$HTTPSADMIN', 'TRACESVR', 'CTXSYS', 'DBA', 'DELETE_CATALOG_ROLE', 'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS ADMIN_ROLE', 'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'MDSYS', 'ODM', ' OEM MONITOR', 'OLAPSYS', 'ORDSYS', 'OUTLN', 'RECOVERY CATALOG OWNER', 'SELEC T_CATALOG_ROLE', 'SNMPAGENT', 'SYSTEM', 'WKSYS', 'WKUSER', 'WMSYS', 'WM_ADMIN ROLE', 'XDB', 'LBACSYS', 'PERFSTAT', 'XDBADMIN')
	and grantee not in (select grantee from dba_role_privs where granted_role='DBA') 
--	and grantee not like '%PROSYNC%'
order by grantee;

--select grantee,owner,table_name,privilege 
--from dba_tbl_privs
--where grantor not in ('SYS','SYSCAT','DBA')
--and grantee not in ('SYS','SYSCAT','DBA') 
--and owner in ('SYS','SYSCAT');

!echo "==============="
!echo " User Role     "
!echo "==============="

set linesize 200
col grantee for a20
col granted_role for a20
col admin_option for a15
col default_role for a15


select grantee, granted_role from dba_role_privs where grantee not in ('SYS','OUTLN');


