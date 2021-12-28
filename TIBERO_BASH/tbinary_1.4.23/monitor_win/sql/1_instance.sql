set feedback off
set linesize 140

col "Instance Name"  format a15
col "Database Name"  format a15
col "Version"        format a20
col "Status"         format a12
col "NLS Character"  format a20
col "Log Mode"       format a13
col "DB Create Time" format a20
col "DB Uptime"      format a15

select i.instance_name "Instance Name"
       , d.name "Database Name"
       , v.vv "Version"
       , d.open_mode "Status"
       , c.cc "NLS Character"
       , d.log_mode "Log Mode"
       , to_char(d.create_date,'YYYY/MM/DD HH24:MI:SS') "DB Create Time"
       , floor(xx)||'d '||floor((xx-floor(xx))*24)||'h '||floor( ((xx - floor(xx))*24 - floor((xx-floor(xx))*24) )*60 )||'m' as "DB Uptime"
from v$database d
     , ( select instance_name, (sysdate-startup_time) xx
         from v$instance
       ) i
     , ( select aggr_concat(value, ' ') vv
         from v$version
         where name in ('PRODUCT_MAJOR', 'PRODUCT_MINOR', 'BUILD_NUMBER', 'STABLE_VERSION')
        ) v
     , ( select aggr_concat(value, '/') cc
         from _dd_props
         where name in ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET')
        ) c
/

exit

