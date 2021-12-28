!echo "------------------------------  1. list of changed password ------------------------------"
!cat $TB_DLOG | grep 'alter user' | grep tibero
!cat $TB_DLOG | grep 'alter user' | grep tibero1
!echo "------------------------------------------------------------------------------------------"


set linesize 200; 
set pagesize 500
     col profile for a15
     col resource_name for a30
     col limit for a20

!echo "=================="
!echo " List of Profile  "
!echo "=================="
select distinct(profile) from dba_profiles where resource_type='PASSWORD';

!echo "======================="
!echo " List of User Profile  "
!echo "======================="
col username for a30
select a.username, dba.profile from all_users as a, dba_users as dba where a.username=dba.username;


