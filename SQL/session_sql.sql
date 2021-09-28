/* Current SQL Info for Session) */
SELECT
	sid,
	serial#,
	'{' || aggr_concat(sql_text, ' ' ORDER BY PIECE) || '}' SQL
FROM
	V$SESSION vs,
	V$SQLTEXT vst
WHERE
	vs.sql_id = vst.sql_id
GROUP BY
	SID, SERIAL#;
