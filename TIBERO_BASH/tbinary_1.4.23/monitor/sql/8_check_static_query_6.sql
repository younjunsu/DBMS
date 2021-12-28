set lines 150
set pages 120
set feedback off
@$MONITOR/sql/sqlid_format.sql

select 'Pattern #' || lpad(row_number() over(order by cnt desc),3,'0') pattern_no,
 sql_id, sql_pattern, cnt
   from(
    select substr(sql_text,1,40) sql_pattern, min(sql_id || '/' || child_number) SQL_ID, count(*) cnt 
    from v$sql
    group by substr(sql_text,1,40)
    having count(*) > 5
   )order by cnt

/

exit
