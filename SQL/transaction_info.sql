/* TRANSACTION INFO */
SELECT
	distinct vs.sid,
	vs.serial#,
	vs.username,
	vs.username || '.' || va.object "OBJECT",
	vs.status,
	vt.used_blk,
	vt.usn,
	vt.start_time,
	floor(mod((sysdate - vt.start_time) * 24, 24)) || ':' ||
		lpad(floor(mod((sysdate - vt.start_time) * 1440, 6)), 2, 0) || ':' ||
		lpad(floor(mod((sysdate - vt.start_time) * 86400, 60)), 2, 0) AS "Transaction Time",
	vst.sql_text
FROM
	V$SESSION vs,
	vt_transaction vt,
	V$SQLTEXT vst,
	V$ACCESS va
WHERE
	vt.sess_id = vs.sid AND
	vt.sess_id = va.sid AND
	NVL(vs.sql_id, vs.prev_sql_id) = vst.sql_id;
