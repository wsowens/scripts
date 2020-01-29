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

# Quickly read the number of pending / running jobs for a user


if [ "$1" = "" ]
then
    echo "Usage: slurm_state [user]"
    exit 255
fi

job_list=$(squeue -u ${1} -o %T)
pending=$(echo "$job_list" | grep -ic "pending")
running=$(echo "$job_list" | grep -ic "running")

echo "[${pending}] Pending | [${running}] Running"
