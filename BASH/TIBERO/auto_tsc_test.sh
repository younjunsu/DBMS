#!/bin/bash
node=$1
interval=1

if [ "$node" = "o" ]; then
    su - observer -c 'tbcmobs -b'
    while true;
    do
        service firewalld stop
        su - observer -c 'cmrctl show --tscid 11'
        su - observer -c 'cmrctl show'
        sleep 3
        clear
    done
elif [ "$node" = "p" ]; then
    source /tibero/.bash_profile
    tbcm -b
    chown -R tibero:dba /tibero/tibero6
    su - tibero -c 'tbboot'
    while true;
    do
        service firewalld stop
        su - tibero -c 'cmrctl show'
        su - tibero -c 'cmrctl show param'
        sleep 3
        clear
    done
elif [ "$node" = "s" ] ; then
    source /tibero/.bash_profile
    tbcm -b
    chown -R tibero:dba /tibero/tibero6
    su - tibero -c 'tbboot recovery'
    while true;
    do
        su - tibero -c 'cmrctl show'
        su - tibero -c 'cmrctl show param'
        sleep 3
        clear
    done
else
    exit
fi