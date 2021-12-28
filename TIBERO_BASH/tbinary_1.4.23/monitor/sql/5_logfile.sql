set feedback off
set linesize 100

col "Group#" format 9999999
col "Member" format a60
col "Type"   format a8
col "Size(MB)" format 9,999,999

SELECT vl.group# "Group#", vlf.member "Member", vlf.type "Type" , vl.bytes/1024/1024 as "Size(MB)"
FROM v$log vl, v$logfile vlf
WHERE vl.group# = vlf.group#
/

exit

