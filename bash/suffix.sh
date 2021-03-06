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

if [[ ${#@} -lt 2 ]]
then
    >&2 echo -e "Usage: suffix [suffix] [file1] ... [fileN]"
    >&2 echo -e "Applies a suffix to each file."
    exit
fi

suffix=$1
for file in ${@:2}
do
    test=${file}${suffix}
    if [[ -e "${test}" ]]
    then
        >&2 echo -e "Error: a file named ${test} already exists. Aborting."
        exit
    fi
done

for file in ${@:2}
do
    mv $file "${file}${suffix}"
done
