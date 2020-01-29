#!/bin/bash
# removing the unaligned reads at the bottom
# then cutting out the third column (mapped reads)
# then summing with awk
if [[ $1 == "" ]]
then
    echo "Usage: mapped_reads [bam file]"
    exit -1
fi
if [[ $HPC_SAMTOOLS_DIR == "" ]]
then
   echo "Error. Must load samtools module." 1>&2
   exit -1
fi
samtools idxstats $1 | head -n-1 | grep -v "ChrM\|ChrC" | cut -f3 | awk '{s+=$1}END{print s}'
