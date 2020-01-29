#!/bin/env python
'''script to take raw BED files from dmap2 and convert them into bigwigs'''
from __future__ import print_function
import sys
import os
import subprocess

FILTER_DIR = "filtered/"
FIX_DIR = "fixed/"
NUC_DIR = "nuclear/"
METH_DIR = "meth/"
COV_DIR = "cov/"
bedGraphToBigWig = "/ufrc/riva/wowens/apps/bin/ucsc/bedGraphToBigWig"
CHROMS = "/ufrc/riva/wowens/chrom.sizes/hg38.chrom.sizes"

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def args_to_string(arglist):
    args = []
    kwargs = {}
    for arg in arglist:
        if "=" in arg:
            splt = arg.split("=")
            key = splt[0]
            try:
                value = eval("=".join(splt[1::]))
            except NameError:
                value = "=".join(splt[1::])
            kwargs[key] = value
        else:
            args.append(arg)
    return args, kwargs


def main(bedfile, filter_dir=FILTER_DIR, fix_dir=FIX_DIR,  nuc_dir=NUC_DIR,
         meth_dir=METH_DIR, cov_dir=COV_DIR, bgtbw=bedGraphToBigWig,
         chroms=CHROMS, nuc_regex="'^ChrM|^ChrC'", filt=10):
    for fdir in [filter_dir, fix_dir, nuc_dir, meth_dir, cov_dir]:
        check_dir(fdir)
    eprint("filtering %s" % bedfile)
    subprocess.call(["filtercov", str(filt), bedfile])
    fn = bedfile.strip(".bed") + ".%i" % filt + ".bed"
    eprint("moving %s to %s" % (fn, filter_dir + fn))
    os.rename(fn, filter_dir + fn)
    new_fn = fn.strip(".bed") + ".fixed.bed"
    eprint("fixing %s and placing result in %s"
           % (filter_dir + fn, fix_dir + new_fn))
    subprocess.call(["fixdmap", filter_dir + fn, fix_dir + new_fn])
    fn = new_fn
    new_fn = fn.strip(".bed") + ".nuclear.bed"
    eprint("filtering non-nuclear dna in %s -> %s"
           % (fix_dir + fn, nuc_dir + new_fn))
    with open(nuc_dir + new_fn, 'w') as nuc_file:
        subprocess.call(["grep", "-Eiv", nuc_regex, fix_dir + fn],
                        stdout=nuc_file)
    meth_fn = meth_dir + new_fn.strip(".bed") + ".meth.bed"
    cov_fn = cov_dir + new_fn.strip(".bed") + ".cov.bed"
    eprint("cutting %s into meth bedGraph %s"
           % (nuc_dir + new_fn, meth_fn))
    with open(meth_fn, 'w') as meth_file:
        subprocess.call(["cut", "-f1-4", nuc_dir + new_fn], stdout=meth_file)
    eprint("sorting")
    with open(meth_fn + "sorted", 'w') as sorted_file:
        subprocess.call(["sort", "-u", "-k1,1", "-k2,2n", meth_fn],
                        stdout=sorted_file)
    os.rename(meth_fn + "sorted", meth_fn)
    eprint("convering to bigwig")
    meth_bw = meth_fn.strip(".bed") + ".bw"
    subprocess.call([bedGraphToBigWig, meth_fn, chroms, meth_bw])
    eprint("cutting %s into cov bedGraph %s"
           % (nuc_dir + new_fn, cov_fn))
    with open(cov_fn, 'w') as cov_file:
        subprocess.call(["cut", "-f1-3,5", nuc_dir + new_fn], stdout=cov_file)
    eprint("sorting")
    with open(cov_fn + "sorted", 'w') as sorted_file:
        subprocess.call(["sort", "-u", "-k1,1", "-k2,2n", cov_fn],
                        stdout=sorted_file)
    os.rename(cov_fn + "sorted", cov_fn)
    eprint("convering to bigwig")
    cov_bw = cov_fn.strip(".bed") + ".bw"
    subprocess.call([bedGraphToBigWig, cov_fn, chroms, cov_bw])


def check_dir(dirname):
    if os.path.exists(dirname):
        assert(os.path.isdir(dirname))
    else:
        try:
            os.mkdir(dirname)
        except OSError:
            pass


if __name__ == "__main__":
    args, kwargs = args_to_string(sys.argv[1::])
    assert(len(args) == 1)
    for fdir in ["filter_dir", "fix_dir", "nuc_dir", "meth_dir", "cov_dir"]:
        if fdir in kwargs:
            if not kwargs[fdir].endswith("/"):
                kwargs[fdir] += "/"
    eprint("Processing %r with these parameters %r" % (args, kwargs))
    main(*args, **kwargs)
