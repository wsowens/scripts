#!/bin/env python
'''script to produce well-ordered directories of sequence data'''
from __future__ import print_function
import os
import sys
import shutil
import re

# modify this regex to match your files
# group1 should be the condition identifier
# group2 should be the lane identifer
# group3 should be the read
matcher = re.compile(r"(M\d-N\d-(?:10)?0U).*(?:.*)(L00\d).*(R\d).*fastq.gz")


# dictionary representing the different conditions
# this should map match.groups(1) -> identifier
# leave this blank to simply use the literal matched text as identifier
COND_GROUP = {
}


# dictionary representing the different lanes
# this should map match.groups(2) -> identifier
# leave this blank to simply use the literal matched text as identifier
LANE_GROUP = {
}

README_TEXT = '''# %s

This directory contains a list of symbolic links that will make the sequence data easier to analyze.

All these files have been organized in a configuration file, %ssamples.conf.
Simply append this file to the end of your dmap2 or atacseq configuration file.

All original data are kept intact here:
'''


def eprint(*args, **kwargs):
    '''print to stderr'''
    print(*args, file=sys.stderr, **kwargs)


def main(*files, target=None):
    '''run the script on [files]
    all files are placed in directory [target]
    if target is not provided, the current directory is used'''
    if not target:
        target = os.getcwd()
    if not target.endswith("/"):
        target += "/"
    # dictionary to track moves
    moves = {} 
    # create a symlink to each file
    for f in files:
        os.symlink(f, target + os.path.basename(f))
        moves[target + os.path.basename(f)] = f
    # dictionary to build the representation of the config file
    conf_dict = {}
    # for each symlink
    for filename in list(moves.keys()):
        # print out the file
        base = os.path.basename(filename)
        print()
        print("File:    " + base)
        # attempt to match the filename to the regex
        match = matcher.match(base)
        if match:
            # extract the condition, lane,a nad read
            if COND_GROUP and match.group(1) not in COND_GROUP:
                print("Skipping due to unrecognized condition")
                del moves[filename]
                os.remove(filename)
                continue
            if LANE_GROUP and match.group(2) not in LANE_GROUP:
                print("Skipping due to unrecognized condition")
                del moves[filename]
                os.remove(filename)
                continue
            cond = COND_GROUP[match.group(1)] if COND_GROUP else match.group(1)
            lane = LANE_GROUP[match.group(2)] if LANE_GROUP else match.group(2)
            read = match.group(3)
            print("cond:    %s" % (cond,))
            print("lane:    %s" % (lane,))
            print("read:    %s" % (read,))
            path = target + cond + "/" + lane + "/" + base
            # store relevant information in the configuration dict
            if cond not in conf_dict:
                conf_dict[cond] = {}
            if lane not in conf_dict[cond]:
                conf_dict[cond][lane] = []
            conf_dict[cond][lane].append(os.path.abspath(path))
            # rename the file (create directories as necessary
            print("Moving to: " + path)
            os.renames(filename, path)
        # if the file cannot be matched, simply remove it
        else:
            del moves[filename]
            os.remove(filename)
            print("Could not match")

    # write the readme file
    with open(target + "README.md", 'w') as readme:
        readme.write(README_TEXT % (target, target))
        for new, original in moves.items():
            readme.write("%s -> %s\n" % (original, new))
    # make a copy of this script
    shutil.copy(os.path.abspath(__file__), target)
    # write out the configuration file
    write_conf(conf_dict, (target + "samples.conf"))


def args_to_string(arglist):
    args = []
    kwargs = {}
    for arg in arglist:
        if "=" in arg:
            splt = arg.split("=")
            key = splt[0]
            value = eval("=".join(splt[1::]))
            kwargs[key] = value
        else:
            args.append(arg)
    return args, kwargs


def write_conf(conf_dict, filename=None):
    '''function to write config file based on files in conf_dict
    if filename is not provided, the config is written
    to standard output
    '''
    if not filename:
        handle = sys.stdout
    else:
        handle = open(filename, 'w')
    conds = list(conf_dict)
    conds.sort()
    # writing out the original sample definitions
    for cond in conds:
        handle.write("[%s]\n" % (cond,))
        lanes = list(conf_dict[cond])
        lanes.sort()
        lanes = map(lambda x: cond + "_" + x, lanes)
        handle.write("samples = %s\n\n" % ", ".join(lanes))

    # writing out the files for each sample
    for cond in conds:
        lanes = list(conf_dict[cond])
        lanes.sort()
        for lane in lanes:
            reads = conf_dict[cond][lane]
            reads.sort()
            handle.write("\n[%s_%s]\n" % (cond, lane))
            if len(reads) == 1:
                handle.write("fastq =" + reads[0] + "\n")
            elif len(reads) == 2:
                handle.write("left  = " + reads[0] + "\n")
                handle.write("right = " + reads[1] + "\n")
            else:
                # protocol calls for r1_left, r1_right, r2_left ...
                # this could be disastrous if we the reads aren't
                # paired up correctly
                eprint(reads)
                raise Exception("Expected only 1 or 2 reads")
    if filename:
        handle.close()


if __name__ == "__main__":
    #parse the sys.argv for position and keyword arguments to main
    args, kwargs = args_to_string(sys.argv[1::])
    for filename in args:
        assert(os.path.exists(filename))
    if "target" in kwargs:
        if os.path.exists(kwargs["target"]):
            assert(os.path.isdir(kwargs["target"]))
        else:
            os.mkdir(kwargs["target"])
    main(*args, **kwargs)
