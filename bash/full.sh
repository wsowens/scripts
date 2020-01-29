#!/bin/bash
dir=$(pwd -P)
for arg in $@
do
    echo "${dir}/${arg}"
done
