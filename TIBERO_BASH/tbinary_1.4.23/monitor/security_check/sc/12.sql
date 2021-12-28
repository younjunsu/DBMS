set linesize 200  
col username for a15
col account_status for a15
col lock_date for a15
col expiry_date for a15

select username, account_status, lock_date, expiry_date from dba_users where username in ('TIBERO','TIBERO1');

