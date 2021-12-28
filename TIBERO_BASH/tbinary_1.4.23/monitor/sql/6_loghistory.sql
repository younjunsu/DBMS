set lines 132
set feedback off


SELECT 'Hourly 00  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23' AS "LOG HISTORY (Since Last Month)" FROM dual
UNION ALL
SELECT '-------------------------------------------------------------------------------------------------------' FROM dual
UNION ALL
SELECT TO_CHAR(first_time,'MM/DD') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'00',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'01',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'02',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'03',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'04',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'05',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'06',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'07',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'08',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'09',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'10',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'11',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'12',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'13',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'14',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'15',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'16',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'17',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'18',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'19',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'20',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'21',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'22',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'23',1,0)),'99') ||'|'   
       as Loghistory 
FROM v$archived_log
WHERE first_time >= add_months(sysdate,-1)
GROUP BY TO_CHAR(first_time,'MM/DD')
UNION ALL
SELECT NULL FROM DUAL
UNION ALL
SELECT '[ARCHIVED LOG COUNT : ' || TO_CHAR(COUNT(*), 999) || ']' AS CNT
FROM v$archived_log
WHERE first_time >= add_months(sysdate,-1)
/

exit

