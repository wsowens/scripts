#!/bin/bash
# Clip a bigwig, to avoid segfaults from wigToBigWig :^|
# Usage:
# clip4wig

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
    echo "clip4bw" 1>&2
    echo "Filters out lines in wig file out of range of chrom.sizes"
    echo "Usage: " 1>&2
    echo "clip4bw chrom.sizes input        [writes result to stdout]" 1>&2
    echo "clip4bw chrom.sizes input output [writes result to file \"output\"]" 1>&2
    exit -1
fi

chroms=$(/ufrc/riva/wowens/apps/bash/collect_chroms.sh ${1})
>&2 echo ${chroms}
if [[ $3 == "" ]]
then
    cat $2 | awk -f /ufrc/riva/wowens/apps/awk/clip_chrom.awk $chroms
else
    cat $2 | awk -f /ufrc/riva/wowens/apps/awk/clip_chrom.awk $chroms > ${3}
fi
