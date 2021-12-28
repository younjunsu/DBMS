set feedback off
set linesize 150
set pagesize 100
col "Sid-Path" for a50

alter session set _inline_with_query=n;

/*
with ttl as (select * from gv$lock, dual)
select path "Sid-Path"
       --, lev "Level"
       --, isleaf
       , type
       , id1
       , id2
       , lmode
       , requested
from (
select substr(sys_connect_by_path('('||nvl(inst_id, 0)||')'||sess_id, '/'), 2) path
       ,level lev
       --,connect_by_isleaf as isleaf
       --,connect_by_iscycle as iscycle  
       , l.*
from ttl l
start with lmode > 0 and requested =0
connect by 
         prior type = type
         and prior id1 = id1
         and prior id2 = id2
         and prior requested != requested
         --and prior nvl(inst_id,0)||prior sess_id != nvl(inst_id, 0)||sess_id
         and requested > 0
         and level < 3
--order siblings by thr_id
) t
where lev = 2 
order by type, path
/
*/

with ttl as (select * from gv$lock, dual)
select path "Sid-Path"
       --, lev "Level"
       --, isleaf
       , type
       , id1
       , id2
       , lmode
       , requested
from (
select substr(sys_connect_by_path('('||nvl(l.inst_id, 0)||')'||sess_id||','||serial#, '/'), 2) path
       ,level lev
       --,connect_by_isleaf as isleaf
       --,connect_by_iscycle as iscycle  
       , l.*
from ttl l , gv$session gs
where l.inst_id = gs.inst_id
  and l.sess_id = gs.sid
start with lmode > 0 and requested =0
connect by
         prior l.type = l.type
         and prior id1 = id1
         and prior id2 = id2
         and prior requested != requested
         --and prior nvl(inst_id,0)||prior sess_id != nvl(inst_id, 0)||sess_id
         and requested > 0
         and level < 3
--order siblings by thr_id
) t
where lev = 2
order by type, path
/

exit
