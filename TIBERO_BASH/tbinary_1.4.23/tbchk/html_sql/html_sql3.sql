select 
       '</tbody></table><br>'||chr(10)||
       '<br><br>'||chr(10)||
       '<p style="page-break-before: always;">[ÂüÁ¶] 4.2 Online Redo Log wsitch Count</p><p>'||chr(10)||
       (
       SELECT aggr_concat(TO_CHAR(first_time,'MM/DD') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'00',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'01',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'02',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'03',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'04',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'05',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'06',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'07',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'08',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'09',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'10',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'11',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'12',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'13',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'14',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'15',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'16',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'17',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'18',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'19',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'20',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'21',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'22',1,0)),'99') ||'|'||
       TO_CHAR(SUM(DECODE(TO_CHAR(first_time,'hh24'),'23',1,0)),'99') ||'|'||'<br>',' ')
       FROM v$archived_log
       GROUP BY TO_CHAR(first_time,'MM/DD')
       ) || '</p>'
from dual;
