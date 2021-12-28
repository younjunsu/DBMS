#!/bin/sh

if [ $# -lt 2 -o $# -gt 3 ]
then
    echo
    echo "Usage : $0 <id> <password> [<connect_string>]"
    echo
    echo '  tbSql wallet add profile    : $ISQL_WALLET_PATH'
    echo '  tbLoader wallet add profile : $LR_WALLET_PATH'
    echo "  Default wallet file path    : $HOME/.wallet.dat"
    echo 
    exit
fi

USER=$1
PASS=$2
CONN=$3

CONN_STR=${USER}/${PASS}@${CONN}
#echo $CONN_STR

if [ ${ISQL_WALLET_PATH-NULL} = "NULL" ]
then

    export ISQL_WALLET_PATH=$HOME/.wallet.dat    ## tbSql wallet file
    #export LR_WALLET_PATH=$HOME/.wallet.dat     ## tbLoader wallet file
fi

#echo $ISQL_WALLET_FILE
#echo $LR_WALLET_FILE

tbsql -s $CONN_STR << EOF
save credential;
exit;
EOF

if [ -f $ISQL_WALLET_PATH ]
then
    chmod 600 $ISQL_WALLET_PATH
    echo "Success make wallet file. [$ISQL_WALLET_PATH]"
else
    echo "Can't make wallet file. [$ISQL_WALLET_PATH]"
fi

