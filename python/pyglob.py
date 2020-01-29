#!/usr/bin/env python 
'''
Wrapper for "glob" function
See:
    https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html
    man 7 glob
'''
from __future__ import print_function
import glob
import sys

for arg in sys.argv[1::]:
    for name in glob.glob(arg):
        print(name)
