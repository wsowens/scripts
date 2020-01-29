# /usr/bin/bash 
if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: quickbg [chrom.sizes] [bedGraph1] ... [bedGraphN] "
    exit -1
fi
if [[ $HPC_DIBIGTOOLS_DIR == "" ]]
then
   echo "Error. Must load dibig_tools module." 1>&2
   exit -1
else
    # storing the path of bedGraphToBigWig
    # if you have a different copy of bedGraphToBigWig, change the path
    # and delete the check above
    bedGraphToBigWig="${HPC_DIBIGTOOLS_DIR}/lib/ucsc/bedGraphToBigWig"
fi
chroms=$1
for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 $bedGraphToBigWig $file $chroms ${file%.bedGraph}.bw  &
done
