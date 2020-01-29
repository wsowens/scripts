#!/bin/bash

if [[ ${#@} -lt 2 ]]
then
    >&2 echo -e "Usage: unprefix [prefix] [file1] ... [fileN]"
    >&2 echo -e "Removes a prefix from each file."
    exit
fi

prefix=$1
for file in ${@:2}
do
    test=${file#${prefix}}
    if [[ -e "${test}" && "${test}" != "${file}" ]]
    then
        >&2 echo -e "Error: a file named ${test} already exists. Aborting."
        exit
    fi
done

for file in ${@:2}
do
    mv $file "${file#${prefix}}"
done
