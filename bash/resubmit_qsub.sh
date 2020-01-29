#!/bin/bash

echo $1
command=$(head -n1 $1 | cut -f2 -d: | xargs)
echo "Command:\n${command}"
echo "Submitting..."
submit $command
