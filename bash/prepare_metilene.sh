#!/bin/bash

# Copyright 2019 William Owens
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this script expects BedGraph files containing methylation data
# for example:
# chrX 100 101 0.3
# if you are using files from cscall / dmap2, you must cut them first
# filter the files as necessary

if [ "$#" -lt 2 ]
then
    >&2 echo "usage: prepare_metilene [chrom.sizes] [group1 files] [group2 files]"
    >&2 echo "group1 and group2 files should be comma-separated"
    exit
fi

# check that users have a working version of bedtools
which bedtools &> /dev/null
if [ "$?" -gt 0 ]
then
    >&2 echo "bedtools not found in path. This script requires bedtools unionbedg."
    >&2 echo "Install bedtools / load the module and rerun this script."
    exit 255
fi

if [ ! -e "$1" ]
then
    >&2 echo "Cannot find chrom.sizes file '${$1}'"
else
    chromsizes="$1"
fi

# processing the group 1 files
g1=()
for f in $(echo $2 | tr , "$IFS")
do
    if [ ! -e "$f" ]
    then
        >&2 echo "Cannot find group 1 file '${f}'"
        exit 255
    fi
    g1+=($f)
done
>&2 echo "group1: ${g1[*]}"

# processing the group 2 files
g2=()
for f in $(echo $3 | tr , "$IFS")
do
    # check that the file exists
    if [ ! -e "$f" ]
    then
        >&2 echo "Cannot find group 2 file '${f}'"
        exit 255
    fi
    g2+=($f)
done
>&2 echo "group2: ${g2[*]}"

# write the header
echo -ne "chr\tpos"
for f in "${g1[@]}"
do
    echo -ne "\tg1_$f"
done
for f in "${g2[@]}"
do
    echo -ne "\tg2_$f"
done
echo ""

# run bedtools, adding "NULL" if a site has no information
bedtools unionbedg --filler NULL -g "$chromsizes" -i ${g1[*]} ${g2[*]} \
     | grep -v "NULL" \
     | cut -f 1-2,4-    
