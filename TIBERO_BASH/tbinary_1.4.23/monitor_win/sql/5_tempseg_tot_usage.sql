set feedback off
set linesize 150
set pagesize 100

col "Temp Name" format a15

select tbs "Temp Name"
       , tot "Total(MB)"
       , use "Used(MB)"
       , tot-use "Free(MB)"
       , round( (tot-use)/tot*100, 1) "Free(%)"
       , ma "Max(MB)"
from (       
	SELECT tf.tablespace_name tbs,
	       round(tf.bytes/1024/1024,2) tot ,
	       nvl2( tu.blocks, round((tu.blocks*pt.value)/1024/1024,2), 0) use,
	       ROUND(tf.MAXBYTES/1024/1024,2) ma      
	FROM
	 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
	   FROM   dba_temp_files
	   GROUP BY tablespace_name) tf,
	 (SELECT tablespace as tablespace_name, sum(blocks) blocks
	   FROM   v$tempseg_usage
	   GROUP BY tablespace) tu
	 ,(select value from _vt_parameter
	   where name = 'DB_BLOCK_SIZE') pt   
	WHERE tf.tablespace_name = tu.tablespace_name(+)
) t
order by 1
/ 

exit

