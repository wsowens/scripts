#!/bin/bash

suffix=$1
for file in ${@:2}
do
    mv $file "${file%${suffix}}"
done
