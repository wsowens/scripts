# /usr/bin/bash 

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
    echo "Usage: quickbw [chrom.sizes] [wig1] ... [wigN] "
    exit -1
fi

# storing the path of wigToBigWig
# if you have a different copy of wigToBigWig, just edit as appropriate
wigToBigWig="/ufrc/riva/wowens/apps/bin/ucsc/wigToBigWig"
chroms=$1

for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 $wigToBigWig -clip $file $chroms ${file%.wig}.bw  &
done
