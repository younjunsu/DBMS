set linesize 300
col username for a15
col profile for a20
col resource_name for a20
col limit for a30
col resource_name for a30

select u.username, p.profile, p.resource_name, p.limit 
from dba_profiles p, dba_users u  
where u.profile = p.profile
and resource_type='PASSWORD'
and resource_name in('PASSWORD_VERIFY_FUNCTION')
order by 1,3;

