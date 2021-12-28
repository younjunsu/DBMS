SET FEEDBACK OFF
SET LINESIZE 120

col "Tablespace Name" format a20
col "Bytes(MB)"       format 999,999,999
col "Used(MB)"        format 999,999,999
col "Percent(%)"      format 9999999.99
col "Free(MB)"        format 999,999,999
col "Free(%)"         format 9999.99
col "MaxBytes(MB)"    format 999,999,999

SELECT ddf.tablespace_name "Tablespace Name",
       ddf.bytes/1024/1024 "Bytes(MB)",
       (ddf.bytes - dfs.bytes)/1024/1024 "Used(MB)",
       round(((ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) "Percent(%)",
       dfs.bytes/1024/1024 "Free(MB)",
       round((1 - ((ddf.bytes - dfs.bytes) / ddf.bytes)) * 100, 2) "Free(%)",
       ROUND(ddf.MAXBYTES / 1024/1024,2) "MaxBytes(MB)"
FROM
 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
   FROM   dba_data_files
   GROUP BY tablespace_name) ddf,
 (SELECT tablespace_name, sum(bytes) bytes
   FROM   dba_free_space
   GROUP BY tablespace_name) dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
ORDER BY ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC;




col "Tablespace Name" format a15 
col "Location"        format a60
col "Size(MB)"        format 9,999,999.99
col "MaxSize(MB)"     format 9,999,999.99

SELECT tablespace_name "Tablespace Name",
       file_name "Location" ,
       bytes/1024/1024 "Size(MB)",
       maxbytes/1024/1024 "MaxSize(MB)"
FROM dba_temp_files;

exit