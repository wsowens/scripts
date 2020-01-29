#!/bin/sh

# prepare files for metilene, the differential DNA metilene tool
# http://www.bioinf.uni-leipzig.de/Software/metilene/

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

if [ "$#" -lt 2 ]
then
    >&2 echo "usage: prepare_metilene [group1 files] [group2 files]"
    >&2 echo "group1 and group2 files should be comma-separated"
    exit
fi

which bedtools &> /dev/null

if [ "$?" -gt 0 ]
then
    >&2 echo "bedtools not found in path. This script requires bedtools unionbedg."
    >&2 echo "Install bedtools / load the module and rerun this script."
    exit 255
fi

g1=()
for f in $(echo $1 | tr , "$IFS")
do
    if [ ! -e "$f" ]
    then
        >&2 echo "Cannot find file ${f}"
        exit 255
    fi
    g1+=($f)
done
>&2 echo "group1: ${g1[*]}"

g2=()
for f in $(echo $2 | tr , "$IFS")
do
    if [ ! -e "$f" ]
    then
        >&2 echo "Cannot find file ${f}"
        exit 255
    fi
    g2+=($f)
done
>&2 echo "group2: ${g2[*]}"

#write the header
echo -ne "chr\tpos\tstop"
for f in "${g1[@]}"
do
    echo -ne "\tg1_$f"
done
for f in "${g2[@]}"
do
    echo -ne "\tg2_$f"
done
echo ""

# run bedtools and cut out the unnecessary "stop" column
# replace the chrom.sizes argument to -g as appropriate
bedtools unionbedg -empty -g ~/chrom.sizes/hg38.chrom.sizes -i ${g1[*]} ${g2[*]}
