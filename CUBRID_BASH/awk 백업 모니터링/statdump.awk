BEGIN {
        system("clear")
        MAXLINES = 30
}
/Num_data_page_fetches/ {
        FETCH=$3
}
/Num_data_page_ioreads/ {
        IOREAD=$3
}
/Num_data_page_iowrites/ {
        IOWRITE=$3
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
}
/Num_query_sscans/ {
        SSCAN=$3
}
/Num_query_iscans/ {
        ISCAN=$3
}
/Num_query_lscans/ {
        LSCAN=$3
}
/Num_query_setscans/ {
        SETSCAN=$3
}
/Num_query_methscans/ {
        METHSCAN=$3
}
/Num_query_nljoins/ {
        NLJOIN=$3
}
/Num_query_mjoins/ {
        MJOIN=$3
}
/Num_sort_io_pages/ {
        SIPAGE=$3
}
/Num_sort_data_pages/ {
        SDPAGE=$3
}
/Num_tran_interrupts/ {
        INTER=$3
}
/Num_network_requests/ {
        NETWORK=$3
}
/Num_page_locks_acquired/ {
        PLAC=$3
}
/Num_object_locks_acquired/ {
        IKAC=$3
}
/Num_page_locks_converted/ {
        PLCON=$3
}
/Num_object_locks_converted/ {
        OLCON=$3
}
/Num_page_locks_re-requested/ {
        PLRE=$3
}
/Num_object_locks_re-requested/ {
        OLRE=$3
}
/Num_page_locks_waits/ {
        PLW=$3
}
/Num_object_locks_waits/ {
        OLW=$3
        if ( cnt == 0) {
               HEADER()
        }
        cnt++
        current=systime()

       printf "%10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s,  %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s,  %10s, %10s, %10s, %10s, %10s \n", strftime("%H:%M:%S", current), FETCH, IOREAD, IOWRITE, SELECT, INSERT, DELETE,UPDATE, SSCAN, ISCAN, LSCAN, SETSCAN, METHSCAN, NLJOIN, MJOIN, SIPAGE, SDPAGE, INTER, NETWORK, PLAC, IKAC, PLCON, OLCON, PLRE, OLRE, PLW, OLW
}

function HEADER() {
        cnt=0
        printf "%10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s,  %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s, %10s,  %10s, %10s, %10s, %10s, %10s \n",  "time", "FETCH", "IOREAD", "IOWRITE", "SELECT", "INSERT", "DELETE", "UPDATE", "SSCAN", "ISCAN", "LSCAN", "SETSCAN", "METHSCAN", "NLJOIN", "MJOIN", "SIPAGE", "SDPAGE", "INTER","NETWORK", "PLAC", "IKAC", "PLCON","OLCON", "PLRE", "OLRE","PLW", "OLW"
}

