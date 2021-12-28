set lines 200
set feedback off
col diskspace for a10
col "DISK STATE" for a10
col REDUN_TYPE for a10


SELECT NAME as DISKSPACE,
       ALLOCATION_UNIT_SIZE/1024 as "AU(KB)",
       STATE,
       TYPE as REDUN_TYPE,
       TOTAL_MB, 
       TOTAL_MB-FREE_MB as USED_MB,
       USABLE_FILE_MB as USABLE_MB
  FROM v$as_diskspace
 ORDER BY NAME
/

exit
