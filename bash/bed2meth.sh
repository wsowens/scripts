#!/usr/bin/bash

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


if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "bed2meth [beds]... "
    echo ""
    echo "Example:"
    echo "bed2meth condition1.bed condition2.bed condition3.bed"
    exit -1
fi

for filename in $@
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 cut -f1-4  $filename > ${filename%.bed}.bedGraph &
done
