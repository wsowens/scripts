# /usr/bin/bash 
if [[ $1 == "" ]] || [[ $2 == "" ]]
then
    echo "Usage: backup [target_dir] [file1] [file2] ... [fileN] "
    exit -1
fi
target=$1
mv -vt ${target} ${@:2} && linkall ${target}/*
