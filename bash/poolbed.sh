#!/bin/sh

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

bedtools_bin=$(which bedtools 2> /dev/null)
if [ "$bedtools_bin" = "" ]
then
    >&2 echo "This script requires 'bedtools' but 'bedtools' cannot be found in PATH."
    exit 255
fi

chroms=$1
bedgraphs=${@:2}

cov_dir=$(mktemp -d)
met_dir=$(mktemp -d)

for f in $bedgraphs
do
    cut -f1-3,5 $f > "${cov_dir}/$(basename ${f})"
    cut -f6 $f | paste -d"," "${cov_dir}/$(basename ${f})" - > "${met_dir}/$(basename ${f})"
    cut_bedgraphs+=("${met_dir}/$(basename ${f})")
done

bedtools unionbedg -g ${chroms} -empty -filler "0,0" -i ${cut_bedgraphs[*]} | awk -e '{
    # iterate over every field and split on commas 
    coverage = 0
    unconverted = 0
    for (i=4; i <= NF; i++)
    {
        split($i, fields, ",")
        coverage += fields[1]
        unconverted += fields[2]
    }
    # if the coverage is 0, omit the field
    if (coverage > 0)
        print $1, $2, $3, unconverted / coverage, coverage, unconverted
}'

rm -r "$cov_dir"
rm -r "$met_dir"
