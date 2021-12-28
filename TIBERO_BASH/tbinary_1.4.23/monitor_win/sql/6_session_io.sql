set linesize 132
set pagesize 100
set feedback off

col "User" format a15
col "Program" format a13
col "Sid" format 999999

SELECT s.sid "Sid"
      ,s.username "User"
      ,s.prog_name "Program"
      ,si.block_gets
      ,si.consistent_gets
      ,si.physical_reads
      ,si.block_changes
      ,si.consistent_changes
FROM  v$session s,
      v$session_io si
WHERE  s.sid = si.sid
ORDER BY s.username, s.sid
/

exit

