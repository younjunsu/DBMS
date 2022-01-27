BEGIN {
        system("clear")
        MAXLINES = 30
}
/Num_data_page_ioreads/ {
        IOREAD=$3
}
/Num_data_page_iowrites/ {
        IOWRITE=$3
}
/Num_data_page_fetches/ {
        FETCH=$3
}
/Num_query_selects/ {
        SELECT=$3
}
/Num_query_inserts/ {
        INSERT=$3
}
/Num_query_deletes/ {
        DELETE=$3
}
/Num_query_updates/ {
        UPDATE=$3

        if ( cnt == 0) {
                HEADER()
        }
        cnt++
        current=systime()

        printf "%10s : %10s, %10s, %10s, %10s, %10s, %10s, %10s \n", strftime("%H:%M:%S", current), SELECT, INSERT, UPDATE, DELETE, FETCH, IOREAD, IOWRITE
        if ( cnt >= MAXLINES ) {
                print ""
                cnt=0
        }
}

function HEADER() {
        cnt=0
        #system("clear")
        print "================================================================================================================================"
        printf "%10s : %10s, %10s, %10s, %10s, %10s, %10s, %10s \n",  "time", "SELECT",  "INSERT",  "UPDATE", "DELETE", "FETCHES", "IO READ", "IO WRITE"
        print "================================================================================================================================"
}
