set feedback off
set linesize 150
set pagesize 100

col username for a15 
col segtype for a15 

SELECT sid
      , username
      , tempseg.sql_id
      , segtype
      , round( (blocks*pt.value)/1024/1024, 2) AS "TEMP(MB)"
      , vst.sql_text
FROM(
  SELECT session_num sid
        , username
        , sql_id
        , segtype
        , sum(blocks) blocks
  FROM   v$tempseg_usage
  GROUP BY session_num, username, sql_id, segtype
) tempseg
, v$sqltext vst
, (select value from _vt_parameter
   where name = 'DB_BLOCK_SIZE') pt
WHERE tempseg.sql_id = vst.sql_id
AND vst.piece = 0
order by sid
/ 

exit

