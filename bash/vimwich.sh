#!/bin/bash

# Equivalent to "vim $(which [command])"
files=()
for i in $@
do
    files+=($(which $i))
done
vim ${files[@]}
