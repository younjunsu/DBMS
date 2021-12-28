set linesize 80
set feedback off

SELECT rlsr "Redo entries", rent "Redo space requests", ROUND(100*(1-rlsr/rent),2) "Redo NoWait %"
FROM 
 (SELECT value rlsr FROM v$sysstat WHERE name = 'redo log space requests'),
 (SELECT value rent FROM v$sysstat WHERE name = 'redo entries')
/

exit

