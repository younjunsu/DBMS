#!/usr/bin/ksh
#-------------------------------------------------------------------------------
# @File name      : smchk.sh
# @Contents       : 
# @Created by     : 
# @Created date   : 
# @Team           : 
# @Modifed History 
# ------------------------------------------------------------------------------
# xxxx.xx.xx xxxxx                 (Verxx)
# ------------------------------------------------------------------------------


### Summary
## Sysmaster Process Update



### JEUS Detail


### Hyperloader Detail


### Repository TIBERO Detail
tbsql sys/tibero @smchk.sql <<EOF
quit
EOF

### Control TIBERO Detail

