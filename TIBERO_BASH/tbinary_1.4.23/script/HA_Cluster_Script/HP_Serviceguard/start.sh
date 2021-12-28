#!/bin/ksh
su - tibero -c "tbdown clean << __EOF__ y __EOF__"
su - tibero -c "tbboot"
exit 0