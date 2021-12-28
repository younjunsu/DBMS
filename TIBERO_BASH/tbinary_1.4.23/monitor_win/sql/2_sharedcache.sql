set linesize 132
set feedback off

col "Time" format a19

SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
       , 'SQL(Library) Cache' AS "Name"
       , hit AS "Hit(%)"
       , CASE WHEN hit > 90 then 'Good'
             WHEN hit between 70 and 90 then 'Average'
             ELSE 'Not Good'
         END AS "Status"
FROM ( SELECT gethitratio AS hit
        FROM v$librarycache
        WHERE namespace= 'SQL AREA' )
UNION ALL
SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
       , 'Dictionary Cache' AS "Name"
       , hit AS "Hit(%)"
       , CASE WHEN hit > 90 then 'Good'
             WHEN hit between 70 and 90 then 'Average'
             ELSE 'Not Good'
         END AS "Status"
FROM ( SELECT ROUND((1- sum(miss_cnt)/(sum(hit_cnt+miss_cnt)))*100, 2) AS hit
        FROM v$rowcache )
/

SELECT TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') AS "Time"
      , 'Shared Cache Free Space' AS "Name"
      , ROUND(used/1024/1024) AS "Used(MB)"
      , ROUND(total/1024/1024) AS "Total(MB)"
      , ROUND((used/total)*100,2) AS "Memory Usage(%)"
FROM v$sga
WHERE name='SHARED POOL MEMORY'
/

SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Time",
    ROUND( (1 - hp.value / (tp.value) ) * 100, 2) "Soft Parse(%)"  
 FROM v$sysstat tp, v$sysstat hp
 WHERE tp.name = 'parse count (total)' 
  and hp.name = 'parse count (hard)'
/

exit

