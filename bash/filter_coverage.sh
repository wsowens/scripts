#!/bin/bash

ext=$1
for file in ${@:2}
do
	sbatch --export=ext=${ext},file=${file} ~/apps/sbatch/filter_coverage.sbatch
done