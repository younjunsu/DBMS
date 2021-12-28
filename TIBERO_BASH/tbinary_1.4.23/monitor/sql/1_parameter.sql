set feedback off
set linesize 80
set pagesize 80

col "Parameter Name" format a40
col "Value" format a25

SELECT name "Parameter Name", value "Value" FROM sys._vt_parameter
WHERE  dflt_value <> value
       OR name in ('OPTIMIZER_MODE', 'EX_MEMORY_AUTO_MANAGEMENT', 
                   'EX_MEMORY_HARD_LIMIT','_WTHR_PER_PROC', 'UNDO_RETENTION')
ORDER BY 1
/

exit

