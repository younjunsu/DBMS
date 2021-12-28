echo ================================================================================================================
echo cmrctl add vip --name vip1 --node cm1 --svcname tac --ipaddr 192.168.56.111/255.255.255.0 --bcast 192.168.56.255
echo cmrctl add vip --name vip2 --node cm2 --svcname tac --ipaddr 192.168.56.112/255.255.255.0 --bcast 192.168.56.255
echo ================================================================================================================
echo
cmrctl add vip --name vip1 --node cm1 --svcname tac --ipaddr 192.168.56.111/255.255.255.0 --bcast 192.168.56.255
cmrctl add vip --name vip2 --node cm2 --svcname tac --ipaddr 192.168.56.112/255.255.255.0 --bcast 192.168.56.255
