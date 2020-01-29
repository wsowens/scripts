#!/usr/bin/bash


if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "bed2cov [beds]... "
    echo ""
    echo "Example:"
    echo "bed2cov condition1.bed condition2.bed condition3.bed"
    exit -1
fi

for filename in $@
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 cut -f1-3,5  $filename > ${filename%.bed}.bedGraph &
done
