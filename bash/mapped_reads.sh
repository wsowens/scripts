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

# removing the unaligned reads at the bottom
# then cutting out the third column (mapped reads)
# then summing with awk

if [[ $1 == "" ]]
then
    echo "Usage: mapped_reads [bam file]"
    exit -1
fi
if [[ $HPC_SAMTOOLS_DIR == "" ]]
then
   echo "Error. Must load samtools module." 1>&2
   exit -1
fi
samtools idxstats $1 | head -n-1 | grep -v "ChrM\|ChrC" | cut -f3 | awk '{s+=$1}END{print s}'
