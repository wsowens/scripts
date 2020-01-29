#!/bin/bash

if [[ ${#@} -lt 2 ]]
then
    >&2 echo -e "Usage: prefix [prefix] [file1] ... [fileN]"
    >&2 echo -e "Applies a prefix to each file."
    exit
fi

prefix=$1
for file in ${@:2}
do
    test=${prefix}${file}
    if [[ -e "${test}" ]]
    then
        >&2 echo -e "Error: a file named ${test} already exists. Aborting."
        exit
    fi
done

for file in ${@:2}
do
    mv $file "${prefix}${file}"
done
