set linesize 130
set feedback off

col "Size" format a20

SELECT name
  , round(total/1024/1024) || '(MB)' AS "Size"
FROM v$sga
WHERE name in ('SHARED MEMORY', 'SHARED POOL MEMORY', 'Database Buffers', 'Redo Buffers')
UNION ALL
SELECT name
  , round(value/1024) || '(KB)' AS "Size"
FROM v$parameters
WHERE name = 'DB_BLOCK_SIZE'
/

exit

