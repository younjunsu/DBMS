--set sqlprompt ""
set lines 200
set feedback off
col name for a6 
col diskspace for a10
col failgroup for a10
col "DISK STATE" for a10
col "DISK_NUMBER/DISKSPACE: PATH" for a40
col TYPE for a10
col "TYPE: FILENAME" for a50

prompt ==============
prompt Diskspace Info
prompt ==============

SELECT NAME as DISKSPACE,
       ALLOCATION_UNIT_SIZE/1024 as "AU(KB)",
       STATE,
       TYPE,
       TOTAL_MB, 
       TOTAL_MB-FREE_MB as USED_MB,
       FREE_MB 
  FROM v$as_diskspace
 ORDER BY NAME
/

prompt
prompt =========
prompt Disk Info 
prompt =========

SELECT d.DISK_NUMBER ||'/' ||ds.name||': ' ||d.PATH as "DISK_NUMBER/DISKSPACE: PATH",
       d.STATE as "DISK STATE", 
       d.OS_MB,
       d.TOTAL_MB,
       d.TOTAL_MB-d.FREE_MB as USED_MB, 
       d.FREE_MB,
       d.FAILGROUP
 FROM v$as_disk d, v$as_diskspace ds
WHERE d.DISKSPACE_NUMBER = ds.DISKSPACE_NUMBER
ORDER BY d.DISKSPACE_NUMBER, d.DISK_NUMBER
/

prompt
prompt =========
prompt File Info 
prompt =========

SELECT f.type ||': '||'+'||ds.name||'/'||a.name as "TYPE: FILENAME",
       f.file_number,
       f.block_size,
       round(f.bytes/1024/1024,2) as "BYTES(MB)",
       f.redundancy,
       f.striped
  FROM v$as_file f, v$as_diskspace ds, v$as_alias a
 WHERE f.diskspace_number = ds.diskspace_number
   AND f.diskspace_number = a.diskspace_number
   AND f.file_number = a.file_number
 ORDER BY f.diskspace_number, f.file_number
/ 
exit
