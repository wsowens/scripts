#!/bin/sh

# I make links to other programs inside this directory, and add it to my PATH
# These links do not need to be tracked, so I made this script to create a 
# fresh gitignore that includes all links in this directory

prelude=\
".*.sw*
__pycache__/*
LOCAL_README.md
# old programs kept for posterity
archive/*
# other binaries
bin/*
"

echo "$prelude" > .gitignore

note=\
"# files below this point are links to other programs
# all of these files can be found either in this repo or in another repo,
# depending upon their author
"

echo "$note" >> .gitignore

find -maxdepth 1 -type l -exec basename {} \; | sort >> .gitignore
