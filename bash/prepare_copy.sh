#!/bin/sh

# fill this in with the name of the server
HOST_NAME="hpg2.rc.ufl.edu"

for f in "$@"
do
    full_path=$(readlink --canonicalize "$f")
    dest_dir=$(dirname "$f")
    echo "mkdir -p ${dest_dir}"
    echo "scp ${USER}@${HOST_NAME}:${full_path} ${dest_dir}"
done
