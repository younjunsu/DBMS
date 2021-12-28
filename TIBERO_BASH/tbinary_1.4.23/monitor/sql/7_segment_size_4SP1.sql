SET LINESIZE 132
SET PAGESIZE 120
SET FEEDBACK OFF

col "Owner" format a20
col "Segment Name" format a30
col "Tablespace Name" format a20
col "Extents" format 999,999,999
col "Size(MB)" format 999,999,999.99

SELECT owner "Owner",
        segment_name as "Segment Name",
        segment_type as "Segment Type",
        tablespace_name as "Tablespace Name",
        extents as "Extents",
        round(bytes/1024/1024,2) as "Size(MB)"
FROM
(
        SELECT  owner,
                segment_name,
                segment_type,
                tablespace_name,
                extents,
                blocks*t.value bytes
        FROM dba_segments d, (select value from vt_parameter where name = 'DB_BLOCK_SIZE') t
        WHERE owner not in ('SYS','SYSGIS','SYSCAT')
        ORDER BY blocks desc
)
WHERE rownum <= 50
/

exit
