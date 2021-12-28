SET LINESIZE 132
SET PAGESIZE 120
SET FEEDBACK OFF

col "Owner" format a20
col "Segment Name" format a30
col "Tablespace Name" format a20
col "Extents" format 999,999,999
col "Size(MB)" format 999,999,999

SELECT owner "Owner",
	segment_name as "Segment Name",
	segment_type as "Segment Type",
	tablespace_name as "Tablespace Name",
	extents as "Extents",
	sizes as "Size(MB)"
FROM
(
	SELECT  owner,
		segment_name,
		segment_type,
		tablespace_name,
		count(segment_name) as extents,
		round(sum(bytes)/1024/1024, 2) as sizes
	FROM dba_extents d
	WHERE owner not in ('SYS','SYSGIS','SYSCAT')
	GROUP BY owner ,segment_name, segment_type, tablespace_name
	HAVING Count(segment_name) > 1
	ORDER BY extents desc, sizes desc, owner, segment_name, segment_type
)
WHERE rownum <= 50
/

exit