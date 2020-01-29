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

if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: quickbg [chrom.sizes] [bedGraph1] ... [bedGraphN] "
    exit -1
fi
if [[ $HPC_DIBIGTOOLS_DIR == "" ]]
then
   echo "Error. Must load dibig_tools module." 1>&2
   exit -1
else
    # storing the path of bedGraphToBigWig
    # if you have a different copy of bedGraphToBigWig, change the path
    # and delete the check above
    bedGraphToBigWig="${HPC_DIBIGTOOLS_DIR}/lib/ucsc/bedGraphToBigWig"
fi
chroms=$1
for file in ${@:2}
do
    srun --ntasks=1 --mem=20gb -t 10:00:00 $bedGraphToBigWig $file $chroms ${file%.bedGraph}.bw  &
done
