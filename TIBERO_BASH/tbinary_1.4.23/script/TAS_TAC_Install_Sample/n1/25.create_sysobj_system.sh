echo ========================================================================================
echo export TB_SID=tac1
echo 
echo sh $TB_HOME/scripts/system.sh -p1 tibero -p2 syscat -a1 y -a2 y -a3 y -a4 y
echo ========================================================================================
echo 

export TB_SID=tac1

sh $TB_HOME/scripts/system.sh -p1 tibero -p2 syscat -a1 y -a2 y -a3 y -a4 y
