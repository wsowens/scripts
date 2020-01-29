#!/usr/bin/bash


if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "bed2meth [beds]... "
    echo ""
    echo "Example:"
    echo "bed2meth condition1.bed condition2.bed condition3.bed"
    exit -1
fi

for filename in $@
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 cut -f1-4  $filename > ${filename%.bed}.bedGraph &
done
