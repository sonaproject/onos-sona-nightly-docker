awkcolor() {
    awk '/INFO/ {print "\033[32m" $0 "\033[39m"}
         /WARN/ {print "\033[33m" $0 "\033[39m"}
         /ERROR/ {print "\033[31m" $0 "\033[39m"}
         /DEBUG/ {print "\033[35m" $0 "\033[39m"}
         /TRACE/ {print "\033[37m" $0 "\033[39m"}
        '
}
