#!/bin/bash
primary_ip="172.24.0.2"
primary_user="tibero"
primary_psw="tibero"
primary_tbuser="sys"
primary_tbpsw="tibero"

standby_ip="172.24.0.3"
standby_user="tibero"
standby_psw="tibero"
standby_tbuser="sys"
standby_tbpsw="tibero"

function ssh_action(){
    sshpass -p "$sshpsw" ssh -o StrictHostKeyChecking=no "$sshuser"@"$sship" "$sshcmd"
}

function primary_node_cmd(){
    sship=$primary_ip
    sshuser=$primary_user
    sshpsw=$primary_psw
    ssh_tbuser=$primary_tbuser
    ssh_tbpsw=$primary_tbpsw
    
    sshcmd="source $HOME/.bash_profile; tail -n 10 $TB_HOME/instance/$TB_SID/log/slog/sys.log"

    ssh_action $sshcmd
}

function standby_node_cmd(){
    sship=$standby_ip
    sshuser=$standby_user
    sshpsw=$standby_psw
    ssh_tbuser=$standby_tbuser
    ssh_tbpsw=$standby_tbpsw
    
    sshcmd="source $HOME/.bash_profile; tail -n 10 $TB_HOME/instance/$TB_SID/log/slog/sys.log"

    ssh_action $sshcmd
}

## function run lists
primary_node_cmd
standby_node_cmd



