#!/bin/bash
# Clip a bigwig, to avoid segfaults from wigToBigWig :^|
# Usage:
# clip4wig

if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "clip4bw" 1>&2
    echo "Filters out lines in wig file out of range of chrom.sizes"
    echo "Usage: " 1>&2
    echo "clip4bw chrom.sizes input        [writes result to stdout]" 1>&2
    echo "clip4bw chrom.sizes input output [writes result to file \"output\"]" 1>&2
    exit -1
fi

chroms=$(/ufrc/riva/wowens/apps/bash/collect_chroms.sh ${1})
>&2 echo ${chroms}
if [[ $3 == "" ]]
then
    cat $2 | awk -f /ufrc/riva/wowens/apps/awk/clip_chrom.awk $chroms
else
    cat $2 | awk -f /ufrc/riva/wowens/apps/awk/clip_chrom.awk $chroms > ${3}
fi
