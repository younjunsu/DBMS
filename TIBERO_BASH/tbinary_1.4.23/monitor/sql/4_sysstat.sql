set feedback off
set linesize 130
set pagesize 50

--col value format 99,999,999,999,999,999

SELECT * FROM
(
  SELECT * FROM v$sysstat 
  WHERE value > 0 
  ORDER BY value DESC
)
WHERE ROWNUM < 40 
/
 
exit

