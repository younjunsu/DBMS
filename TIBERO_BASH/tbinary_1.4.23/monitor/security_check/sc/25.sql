spool results.out
col passwd for a100
select value passwd from vt_parameter where name='DB_CREATE_FILE_DEST';
spool off
!sed -n 4p results.out >> passwd.txt
!rm results.out

