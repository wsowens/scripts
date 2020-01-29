#!/bin/bash

#check that two folders are equivalent

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

# removing the unaligned reads at the bottom
# then cutting out the third column (mapped reads)
# then summing with awk


if [[ "${#@}" -lt 2 ]]
then
    >&2 echo -e "Usage: checkfolder [folder1] [folder2]"
    exit 2
fi

f1=$1
f2=$2

retval=0
for file in $(find $f1 -type f)
do
    file2=${f2}${file#${f1}}
    if [ -a "${file2}" ]
    then 
        hash1=($(md5sum $file))
        hash2=($(md5sum ${f2}${file#${f1}}))
        >&2 echo -e $hash1
        >&2 echo -e $hash2
        if [ "$hash1" != "$hash2" ]; then
            echo "${file} differs"
            retval=1
        fi
    else
        echo "${file#${f1}} not found in ${f2}"
        retval=1
    fi
done

for file in $(find $f2 -type f)
do
    file1=${f1}${file#${f2}}
    if [ ! -f "${file1}" ]
    then
        echo "${file#${f2}} not found in ${f1}"
        retval=1
    fi
done

exit $retval
