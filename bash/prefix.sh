#!/bin/bash

prefix=$1
for file in ${@:2}
do
    mv $file "${prefix}${file}"
done
