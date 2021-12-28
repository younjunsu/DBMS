#!/bin/sh
#####  Create Session Event Select Query  #####
#echo $SHELL
#echo $OS
if [ $OS = "Linux" ] ; then
  echo -e "Enter Session ID (ex: 9,10,12) : \c "
elif [ $OS = "SunOS" ] ; then
  #echo -n "Enter Session ID (ex: 9,10,12) :  "
  echo "Enter Session ID (ex: 9,10,12) : \c "
else
  echo 'Enter Session ID (ex: 9,10,12) : \c '
fi

read SESSION_ID

echo "!echo
!echo Select Session ID : ${SESSION_ID}

set feedback off
set linesize 130
set pagesize 40
col value format 99,999,999,999,999,999
col tid format 9999
col \"DESC\" format a50

select tid, 
       \"DESC\", 
       total_waits,
       total_timeouts,
       time_waited,
       average_wait,
       max_wait 
from V\$SESSION_EVENT
where 1=1 
and tid in ( ${SESSION_ID} )
and time_waited > 0 
order by 1,time_waited desc
/
exit" > $MONITOR/sql/4_session_event.sql

exit 0

