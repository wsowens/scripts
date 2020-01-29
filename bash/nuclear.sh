# /usr/bin/bash 

if [[ $1 == "" ]]
then
    echo "Usage: nuclear [bedGraph1] ... [bedGraphN] "
    exit -1
fi

for file in $@
do
    srun --ntasks=1 --mem=50mb grep -vi ^ChrM $file | grep -vi ^ChrC > "${file%.bed}.nuclear.bed"  &
done
