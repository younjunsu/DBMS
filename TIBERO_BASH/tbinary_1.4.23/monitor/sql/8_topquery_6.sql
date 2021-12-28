
set linesize 150
set feedback off
col USERNAME for A20
col MODULE for A30

@$MONITOR/sql/sqlid_format.sql

-- Top 5 SQL Ordered by Elapsed Time
prompt  ========  Top 10 SQL Ordered by Elapsed Time =========

select * from
(
select (select username from all_users where user_id = PARSING_USER_ID ) USERNAME,
							round(ELAPSED_TIME/1000000,3) as "Elapsed_Time(s)",
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/EXECUTIONS/1000,3) as "Elap/Exec(ms)",
       MODULE "MODULE",
       sql_id|| '/' || child_number "SQL_ID"
from v$sql
where ELAPSED_TIME > 0
and EXECUTIONS > 0
order by 2 desc
) where rownum <=10
/

prompt
prompt  ========  Top 10 SQL Ordered by gets =============

select * from
(
select (select username from all_users where user_id = PARSING_USER_ID ) USERNAME,
       BUFFER_GETS,
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/1000000,3) "Elapsed_Time(s)",
       MODULE "MODULE",
       sql_id|| '/' || child_number "SQL_ID"
from v$sql
where ELAPSED_TIME > 0
and EXECUTIONS>0
--and rownum <=10
order by 2 desc
) where rownum <=10
/

prompt
prompt  ========  Top 10 SQL Ordered by Elap/Exec(ms) =============

select * from
(
select (select username from all_users where user_id = PARSING_USER_ID ) USERNAME,
       round(ELAPSED_TIME/EXECUTIONS/1000,3) as "Elap/Exec(ms)",
       EXECUTIONS,
       round(BUFFER_GETS/EXECUTIONS,3) "Gets/Exec",
       round(ELAPSED_TIME/1000000,3) "Elapsed_Time(s)",
       MODULE "MODULE",
       sql_id|| '/' || child_number "SQL_ID"
from v$sql
where ELAPSED_TIME > 0
and EXECUTIONS>0
--and rownum <=10
order by 2 desc
) where rownum <=10
/

exit
