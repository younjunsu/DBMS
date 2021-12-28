#!/usr/bin/ksh
#-------------------------------------------------------------------------------
# @File name      : tbchk.sh
# @Contents       : Tibero RDBMS CSR Ver1.3
# @Created by     : Kim shi youl
# @Created date   : 2010.07.01
# @Team           : DB Tech
# @Modifed History 
# ------------------------------------------------------------------------------
# 2010.07.31 Kim shi youl                 (Ver1.0)
# 2011.03.15 Gim gwon hwan Modified       (Ver1.1)
# 2011.03.17 Gim gwon hwan Modified       (Ver1.2)
# 2011.03.25 Gim gwon hwan Modified       (Ver1.3)
# 2017.03.20 Yeo Han Na Modified          (Ver1.4.8)
# 2018.08.18 Kim Jin Young Modified       (Ver1.4.10)
# ------------------------------------------------------------------------------

tbsql sys/tibero @tbcheck_for_6.sql <<EOF
quit
EOF
