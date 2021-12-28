col users for a20
select username users from dba_users 
where username not in('SYS','SYSCAT','SYSGIS','OUTLN');

