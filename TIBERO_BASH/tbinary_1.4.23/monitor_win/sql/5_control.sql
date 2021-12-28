set feedback off
set linesize 132

col "Control Files" format a87


SELECT name  "Control Files" FROM v$controlfile
/

exit

