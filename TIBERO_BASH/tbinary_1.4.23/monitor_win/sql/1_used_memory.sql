set linesize 130
set feedback off

select name, round(value/1024/1024, 2) "Size(MB)"
from v$parameters
where name = 'MEMORY_TARGET'
union all
select 'SGA(Used)' name, round(sum(used)/1024/1024, 2) "Size(MB)"
from v$sga
where name in ('FIXED MEMORY', 'SHARED POOL MEMORY')
union all
select 'PGA(Allocated)' name, round(sum(value)/1024/1024, 2) "Size(MB)"
from v$pgastat
where name in ('FIXED pga memory', 'ALLOCATED pga memory')
union all
select 'PGA(Used)' name, round(value/1024/1024, 2) "Size(MB)"
from v$pgastat
where name = 'USED pga memory (from ALLOCATED)'
/

exit

