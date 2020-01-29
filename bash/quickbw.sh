# /usr/bin/bash 
if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: quickbw [chrom.sizes] [wig1] ... [wigN] "
    exit -1
fi

# storing the path of wigToBigWig
# if you have a different copy of wigToBigWig, just edit as appropriate
wigToBigWig="/ufrc/riva/wowens/apps/bin/ucsc/wigToBigWig"
chroms=$1

for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 $wigToBigWig -clip $file $chroms ${file%.wig}.bw  &
done
