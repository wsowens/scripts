#!/usr/bin/awk -f
BEGIN {
    MAPPED=0;
    UNMAPPED=0;
}
{
    if ($1 != "*")
    {
        MAPPED+=$3;
    }
    UNMAPPED+=$4;
}
END {
    print OFS MAPPED, UNMAPPED;
}
        
