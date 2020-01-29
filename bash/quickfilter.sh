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

if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: "
    echo "quickfilter '[coverages]...' [beds]... "
    echo ""
    echo "Example:"
    echo "quickfilter '10 30 100' condition1.bed condition2.bed condition3.bed"
    exit -1
fi

# storing the path of filtercov, the Rust program from wowens
# if you have a different copy of filtercov, just edit as appropriate
filtercov_bin="/ufrc/riva/wowens/apps/rust/filtercov/target/release/filtercov"
coverage=$1
for filename in ${@:2}
do
	srun --ntasks=1 --mem=5gb -t 10:00:00 $filtercov_bin "${coverage}" $filename &
done
