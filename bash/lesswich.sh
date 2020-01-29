#!/bin/bash

# Equivalent to "less $(which [command])"

files=()
for i in $@
do
    files+=($(which $i))
done
less ${files[@]}
