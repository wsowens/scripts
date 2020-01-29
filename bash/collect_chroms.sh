#!/bin/bash
cat $1 | awk -v ORS=' ' 'BEGIN{OFS = "="} {print $1, $2}'

