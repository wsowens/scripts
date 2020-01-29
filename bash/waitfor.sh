#!/bin/bash

#"Usage: waitfor [files] [count] [message]

regex=$1
total=$2
message=$3

count=0
echo -n "${message} ${count}"
while [[ $count -lt $total ]]
do
    sleep 5
    count=$(pyglob $regex 2> /tmp/trash | wc -l)
    echo -ne "\b${count}"
done
echo -e "\bdone."
