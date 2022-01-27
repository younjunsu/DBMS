#!/bin/bash
# create by junsuyoun
telnet_check_ip=
telnet_check_port=
telnet_check_log_path=

telnet_check_runtime=`date +%s`
telnet_check=`telnet $telnet_check_ip $telnet_check_port |exit`
telnet_check_endtime=`date +%s`

telnet_check_difftime=`expr "$telnet_check_endtime - telnet_check_runtime"`

if [ $telnet_check_]; then
	2>/dev/null
else
	date >> $telnet_check_log_path
	echo $telnet_check_difftime >> telnet_check_log_path
fi
