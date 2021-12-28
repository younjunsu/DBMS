set feedback off
set linesize 150
set pagesize 100
col "Sid-Path" for a40

select path "Sid-Path"
       --, lev "Level"
       --, isleaf
       , type
       , id1
       , id2
       , lmode
       , requested
from (
select  substr(sys_connect_by_path(thr_id, '/'), 2) path
       ,level lev
       --,connect_by_isleaf as isleaf
       --,connect_by_iscycle as iscycle  
       , l.*
from v$lock l
start with lmode > 0 and requested =0
connect by 
         prior type = type
         and prior id1 = id1
         and prior id2 = id2
         and prior requested != requested
         --and prior thr_id != thr_id
         and requested > 0
         and level < 3
--order siblings by thr_id
) t
where lev = 2 
order by type, path
/

exit
