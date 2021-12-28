set linesize 132
set feedback off
set pagesize 50
col size for 9999999999

SELECT * FROM 
(
  SELECT b.name AS name
      , SUM(num) AS num
      , SUM("SIZE") AS "SIZE"
      , ROUND(SUM(a.time)/1000000,4) AS time_sec
  FROM vt_jcntstat a, vt_jcntstat_name b
  WHERE a.jcnt# = b.jcnt#
  GROUP BY b.name, a.jcnt#
  HAVING (SUM(num) > 0 OR SUM("SIZE") > 0 OR SUM(a.time) > 0 )
  ORDER BY time_sec DESC 
)
WHERE time_sec > 0 
AND ROWNUM < 40
/

exit

