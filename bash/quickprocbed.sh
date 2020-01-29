#!/bin/bash


# note you can supply semicolon separated values with
# the "kwargs" flag, just be sure to wrap it in quotes
# i.e.
# quickprocbed --kwargs "filt=10;cov_dir=30" a.bed b.bed
# if you need spaces in the kwargs, you're basically screwed

bedfiles=()
for arg in $@
do
    if [ "$prev" = "--kwargs" ]
    then
        kwargs=$(echo "$arg" | tr ";" "$IFS")
    elif [ "$arg" != "--kwargs" ]
    then
        bedfiles+=("$arg")
    fi
    prev=$arg
done

>&2 echo "Processing these bedfiles: ${bedfiles[@]}"
>&2 echo "With these kwargs: ${kwargs[@]}"
for f in ${bedfiles[*]}
do
    if [ "$kwargs" = "" ]
    then
        echo "srun -t 45:00 --mem 10G process_bed ${f} &> ${f%.bed}.proc &"
        srun -t 45:00 --mem 10G process_bed ${f} &> ${f%.bed}.proc &
    else
        echo "srun -t 45:00 --mem 10G process_bed ${kwargs} ${f} &> ${f%.bed}.proc &"
        srun -t 45:00 --mem 10G process_bed ${kwargs} ${f} &> ${f%.bed}.proc &
    fi 
done
