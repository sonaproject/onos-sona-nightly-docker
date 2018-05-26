awkcolor() {
    # INFO:  Cyan   (36m)
    # WARN:  Yellow (33m)
    # ERROR: Red    (31m)
    # DEBUG: Purple (35m)
    # TRACE: Green  (32m)
    awk '/INFO/ {print "\033[36m" $0 "\033[39m"}
         /WARN/ {print "\033[33m" $0 "\033[39m"}
         /ERROR/ {print "\033[31m" $0 "\033[39m"}
         /DEBUG/ {print "\033[35m" $0 "\033[39m"}
         /TRACE/ {print "\033[32m" $0 "\033[39m"}
        '
}
