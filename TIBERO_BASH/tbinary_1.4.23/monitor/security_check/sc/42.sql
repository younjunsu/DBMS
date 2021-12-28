set linesize 200
col name for a20
col value for a20

SELECT NAME, VALUE FROM V$PARAMETERS WHERE NAME='AUDIT_TRAIL';


!echo "==============="
!echo " Audit Setting "
!echo "==============="
!echo "               "
!cat "$TB_HOME/config/$TB_SID.tip" | grep "AUDIT"
!echo "              " 

