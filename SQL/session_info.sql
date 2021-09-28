/* 현재 세션 정보 (Session Info) */
SELECT 
	TO_CHAR(sysdate, 'yyyy/mm/dd hh24:mi:ss') "Time",
	"Working Process Memory",
	(a.acs + b.run) "Total Sess",
	b.run "Running Sess",
	c.recover "Recover Sess"
FROM
	(
		SELECT 
			SUM(pga_used_mem) "Working Process Memory",
			COUNT(*) acs
		FROM
			V$SESSION
		WHERE
			status='ACTIVE'
	) a,
	(
		SELECT
			COUNT(*) run
		FROM
			V$SESSION
		WHERE
			status='RUNNING'
	) b,
	(
		SELECT
				COUNT(*) recover
		FROM
			V$SESSION
		WHERE
			status = 'SESS_RECOVERING'
	) c;

			
	
	
