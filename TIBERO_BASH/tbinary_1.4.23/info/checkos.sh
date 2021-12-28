#[Tibero OS info]

#!/bin/ksh

echo "Begin  checking your system to install Tibero RDBMS" 

##
# Common 
##

CHKOS=`uname -s`
SI=`uname -a`
DISKSPACE="df -k"


confirm()
{
echo ".=================================================================."  >  checkos.info
echo "| 1. Recent OS patch.                                             |"  >> checkos.info
echo "| 2. Profile : Shared Library Path                                |"  >> checkos.info
echo "| 3. C compiler                                                   |"  >> checkos.info
echo "| 4. 3G DISK SPACE [Product & Logfile]                            |"  >> checkos.info
echo "| 5. 500M Temp[/tmp] SPACE [GUI INSTALL]                          |"  >> checkos.info
echo "| 6. DATAFILE SPACE [default: system file 3G + User datafile]     |"  >> checkos.info
echo "+=================================================================+"  >> checkos.info
echo   >> checkos.info
}

##
## Functions
##

function exechk
{
case "$CHKOS" in
Linux)

echo ".--------------------."   >> checkos.info
echo "| System Information |"  $SI      >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Kernel Bits        |"  `/usr/bin/getconf WORD_BIT`  "bit [Kernel version should be over 2.6]" >>
checkos.info
echo "+--------------------+"   >> checkos.info
echo "| glibc  version     |"   "[glib version should be over 2.3.4]" >> checkos.info
echo "+--------------------+"   >> checkos.info
 /bin/rpm -qa | grep glibc >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Memory Size        |"  `cat /proc/meminfo | grep "MemTotal"`     >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/bin/free >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| CPU Info           |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 cat /proc/cpuinfo | grep "model name"  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| JDK version        |"   "[JDK version should be over 1.4.2]" >> checkos.info
echo "+--------------------+"   >> checkos.info
 java -version   >> checkos.info 2>&1
echo ".--------------------."   >> checkos.info
echo "| Kernel Setting     |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /sbin/sysctl -a | grep 'fs.file-max' >> checkos.info
 /sbin/sysctl -a | grep 'sem'         >> checkos.info
 /sbin/sysctl -a | grep 'shmmax'      >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Disk Space Info    |  ( KB)"   >> checkos.info
echo "+--------------------+" >> checkos.info
 $DISKSPACE >> checkos.info
;;

SunOS)  
LANGV=`echo $LANG`
export LANG=C
echo ".--------------------."   > checkos.info
echo "| System Information |"  $SI      >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Kernel Bits        |"  `/usr/bin/isainfo -kv`  "bit">> checkos.info
echo "+--------------------+"   >> checkos.info
echo "| Memory Size        |"  `/usr/sbin/prtconf | grep size`     >> checkos.info
echo "+--------------------+"   >> checkos.info
echo "| CPU Info           |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
  /usr/sbin/psrinfo -v  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| JDK version        |"   "[JDK version should be over 1.4.2]" >> checkos.info
echo "+--------------------+"   >> checkos.info
 java -version   >> checkos.info 2>&1
echo ".--------------------."   >> checkos.info
echo "| Kernel Setting     |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 sysdef | grep SEM  >> checkos.info
 sysdef | grep SHM  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Disk Space Info    |  ( KB)"   >> checkos.info
echo "+--------------------+" >> checkos.info
 $DISKSPACE >> checkos.info
export LANG=$LANGV
;;

AIX)  
LANGV=`echo $LANG`
export LANG=C
echo ".--------------------."   > checkos.info
echo "| System Information |"  $SI      >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Kernel Bits        |"  `/usr/sbin/prtconf | grep Kernel` >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| libc/libthreads ver|"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/bin/lslpp -L |grep libc >> checkos.info
 /usr/bin/lslpp -L |grep pthread >> checkos.info
echo "[libc, libthreads version should be over 5.2.0.53(AIX5.2) / 5.3.0.53(AIX5.3)]" >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Memory Size        |"  `/usr/sbin/prtconf | grep "Memory Size" `   >> checkos.info
echo "+--------------------+"   >> checkos.info
echo "| CPU Info           |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/sbin/prtconf | grep "Processor Type"  >> checkos.info
 /usr/sbin/prtconf | grep "Number Of Processors"  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| JDK version        |"   "[JDK version should be over 1.4.2]" >> checkos.info
echo "+--------------------+"   >> checkos.info
 java -version   >> checkos.info 2>&1
echo ".--------------------."   >> checkos.info
echo "| Kernel Setting     |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/sbin/lsdev -C | grep aio   >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Disk Space Info    |  ( KB)"   >> checkos.info
echo "+--------------------+" >> checkos.info
 $DISKSPACE >> checkos.info
export LANG=$LANGV
;;

HP-UX)  
echo ".--------------------."   > checkos.info
echo "| System Information |"  $SI      >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Kernel Bits        |"  `/usr/bin/getconf KERNEL_BITS` "bit">> checkos.info
echo "+--------------------+"   >> checkos.info
echo "| Memory Size        |"  `/usr/sbin/dmesg |grep Physical | grep Kbytes |awk '{print $2}'` >> checkos.info
echo "+--------------------+"   >> checkos.info
echo "| CPU Info           |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/sbin/ioscan -fnC processor  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| JDK version        |"   "[JDK version should be over 1.4.2]" >> checkos.info
echo "+--------------------+"   >> checkos.info
 java -version   >> checkos.info 2>&1
echo ".--------------------."   >> checkos.info
echo "| Kernel Setting     |"   >> checkos.info
echo "+--------------------+"   >> checkos.info
 /usr/sbin/sysdef kmtune | grep shm  >> checkos.info
 /usr/sbin/sysdef kmtune | grep sem  >> checkos.info
echo ".--------------------."   >> checkos.info
echo "| Disk Space Info    |  ( KB)"   >> checkos.info
echo "+--------------------+" >> checkos.info
 $DISKSPACE >> checkos.info
;;

*)
echo "Tibero does not support current OS Platform. Please check again!!"
;;

esac
}
############################
#-- Execute check script --#
############################

confirm

exechk


echo "Finish checking your system to install Tibero RDBMS"