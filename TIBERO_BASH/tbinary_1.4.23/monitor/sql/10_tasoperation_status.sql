set lines 200
set feedback off
col "Diskspace Name" for a20 
col operation for a15
col total for 999999999999
col remain for 999999999999
col done for 999999999999
col "EST REMAIN TIME(s)" for 999999999999

SELECT asds.NAME as "Diskspace Name",
       asop.OPERATION,
       asop.JOB_TOTAL as TOTAL,
       asop.JOB_REMAIN as REMAIN,
       asop.JOB_DONE as DONE,
       round(asop.EST_SPEED,2) as SPEED,
       asop.EST_REMAIN_TIME as "EST REMAIN TIME(s)"
 FROM v$as_operation asop, v$as_diskspace asds
WHERE asop.DISKSPACE_NUMBER = asds.DISKSPACE_NUMBER
ORDER BY asop.DISKSPACE_NUMBER
/

exit
