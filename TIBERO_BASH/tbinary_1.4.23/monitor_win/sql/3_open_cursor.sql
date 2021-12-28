set feedback off
set linesize 130

col "COUNT" format 999,999

select sid "SID", count(*) "COUNT" 
from v$open_cursor 
group by sid 
/

exit
