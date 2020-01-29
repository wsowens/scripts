# /usr/bin/bash 
if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: quickcut [fields] [bed1] [bed2]... bed[n]"
    exit -1
fi

fields=$1
for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 cut "-f${fields}" $file > ${file%.bed}.bedGraph &
done
