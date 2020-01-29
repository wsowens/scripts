# /usr/bin/bash 
if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: quickclip [chrom.sizes] [wig1] ... [wigN] "
    exit -1
fi

#change this path if you are using a different clip4bw
clip4bw="/ufrc/riva/wowens/apps/clip4bw/"
chroms=$1
for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 $clip4bw $file $chroms ${file%.wig}.clipped.bw  &
done
