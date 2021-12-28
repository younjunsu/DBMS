set feedback off
set linesize 120
set pagesize 100

col "Tablespace Name" format a20
col "File Name" format a60
col "Size(MB)" format 999,999,999
col "MaxSize(MB)" format 999,999,999

SELECT *
FROM (
	SELECT tablespace_name as "Tablespace Name",
	           file_name as "File Name",
	           bytes/1024/1024 as "Size(MB)",
	           maxbytes/1024/1024 as "MaxSize(MB)"
	FROM dba_data_files
	UNION ALL
	SELECT tablespace_name as "Tablespace Name",
	       file_name as "File Name" ,
	       bytes/1024/1024 "Size(MB)",
	       maxbytes/1024/1024 "MaxSize(MB)"
	FROM dba_temp_files
)
ORDER BY 1,2
/

exit

