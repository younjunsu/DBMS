set lines 200
set feedback off
col failgroup for a15
col "DISK STATE" for a15
col "DISK_NUMBER/DISKSPACE: PATH" for a45

SELECT LPAD(d.DISK_NUMBER,5) ||'/' ||ds.name||': ' ||d.PATH as "DISK_NUMBER/DISKSPACE: PATH",
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

exit
