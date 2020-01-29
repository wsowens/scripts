BEGIN {
    split(ARGV[1], first, "=")
    FIRST_CHROM = first[1]
    FIRST_COUNT = first[2]
}
{
    # testing if this is even a chr line
    if ( !($1 ~ "chr") &&  !($1 ~ "Chr" ) ) {
        split($3, start, "=")
        if (start[1] < FIRST_COUNT)
            print $0
        else {
            print "Skipping" | "cat 1>&2"
            print $0  | "cat 1>&2"
        }
        next
    }
        
    if ( $1 == FIRST_CHROM ) {
        if ( $2 <= FIRST_COUNT ) {
            print $0
        }
        else {
            print "Skipping" | "cat 1>&2"
            print $0  | "cat 1>&2"
        }
        next
    
    }

    for (i = 1; i < ARGC; i++) {
        split(ARGV[i], chrom, "=")
        if ( chrom[1] == $1 ) {
            if ( $3 <= chrom[2] ) {
                print $0
                FIRST_CHROM = chrom[1]
                FIRST_COUNT = chrom[2]
                next
            }
            next
        }
    }
    print $0
}
    
            
