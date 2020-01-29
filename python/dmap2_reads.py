#!/usr/bin/env python
'''dmap2_reads

Created by wowens for the Kladde Lab
'''
from __future__ import print_function
import sys
import re
import os
import subprocess
from glob import glob
import argparse
import pysam


def eprint(*args, **kwargs):
    '''print to stderr'''
    print(*args, file=sys.stderr, **kwargs)


BSMAP_REGEX = re.compile(r'\s(\w\S*(?: [A-Za-z0-9#]+)+):( \S*)')

BSMAP_ATTRIBUTES = {
    "Input read file #1": "input1",
    "Input read file #2": "input2",
    "loading reference file": "reference",
    "Output file": "output",
    "total read pairs": "total",
    "unique pairs": "unique",
    "aligned pairs": "aligned"
}

ATTRIBUTE_TYPES = {
    "Input read file #1": str,
    "Input read file #2": str,
    "loading reference file": str,
    "Output file": str,
    "total read pairs": int,
    "unique pairs": int,
    "aligned pairs": int
}


class BsmapQsub:
    def __init__(self, filename):
        self.filename = os.path.abspath(filename)
        with open(filename) as f:
            data = f.read()
        match_dict = {}
        for match in BSMAP_REGEX.finditer(data):
            match_dict[match.group(1).strip()] = match.group(2).strip()
        for raw_key, attribute in BSMAP_ATTRIBUTES.items():
            setattr(self, attribute,
                    ATTRIBUTE_TYPES[raw_key](match_dict[raw_key]))
        # get sample name from BAM filename
        sample = self.output
        if sample.endswith("_r1.bam"):
            sample = sample[:-7]
        self.sample_name = sample

    def __str__(self):
        attr_list = sorted(BSMAP_ATTRIBUTES.values())
        return "\n".join(["{0:<25}{1}".format(attr, getattr(self, attr)) for attr in attr_list])

    def __repr__(self):
        return "BsmapQsub(%r)" % (self.filename,)


PICARD_ATTRIBUTES = {
    "UNPAIRED_READS_EXAMINED": "unpaired",
    "READ_PAIRS_EXAMINED": "paired",
    "UNMAPPED_READS": "unmapped",
    "UNPAIRED_READ_DUPLICATES": "unpaired_dupes",
    "READ_PAIR_DUPLICATES": "paired_dupes",
    "READ_PAIR_OPTICAL_DUPLICATES": "paired_optical_dupes",
    "PERCENT_DUPLICATION": "percent_dup"
}


class PicardMetrics:
    def __init__(self, filename):
        self.filename = os.path.abspath(filename)
        with open(filename) as f:
            line = f.readline()
            while line:
                if line.startswith("## METRICS CLASS"):
                    break
                line = f.readline()
            else:
                raise ValueError("File does not contain Picard metrics")
            keys = f.readline().split("\t")
            values = f.readline().split("\t")
            assert(len(keys) == len(values))
            temp_dict = dict(zip(keys, values))
        # sample name is simply filename without "-metrics.txt"
        for key, attribute in PICARD_ATTRIBUTES.items():
            setattr(self, attribute, temp_dict[key])
        self.sample_name = filename[:-12]

    def __str__(self):
        attr_list = sorted(PICARD_ATTRIBUTES.values())
        return "\n".join(["{0:<25}{1}".format(attr, getattr(self, attr)) for attr in attr_list])

    def __repr__(self):
        return "PicardMetrics(%r)" % (self.filename,)


class BamFile:
    def __init__(self, filename):
        '''create a representation of a BamFile with [filename]'''
        self.filename = filename
        self._mapped_reads = None
        #pysam.AlignmentFile(filename, 'rb')

    def mapped_reads(self):
        if self._mapped_reads is None:
            self._mapped_reads = pysam.AlignmentFile(self.filename, 'rb').mapped
        return self._mapped_reads


class Sample:
    '''class to couple BsmapQsub, PicardMetric, BamFile'''

    def __init__(self, dirname, bsmap, bam, picard):
        self.name = bsmap.sample_name
        self.dirname = dirname
        self.bsmap = bsmap
        self.bam = bam
        self.picard = picard

    def row(self):
        return [self.name, self.bsmap.total, self.bsmap.aligned,
                self.bsmap.unique, float(self.bsmap.unique) / self.bsmap.total,
                self.bsmap.unique * 2, self.bam.mapped_reads(),
                1 - (float(self.bam.mapped_reads()) / (self.bsmap.unique * 2)),
                self.dirname]



def iter_bsmap(dirname):
    bsmap_qsubs = subprocess.check_output("grep -l \[bsmap\]".split() +
                                           glob(dirname + "/generic.qsub.IN.e*"))
    for fname in bsmap_qsubs.split():
        yield BsmapQsub(fname)


def main(dirs, output):
    samples = []
    for d in dirs:
        # flag to mark if we cannot find a BAM / Picard file
        search_failed = False
        eprint("Scanning directory '%s'..." % d)
        qsubs = list(iter_bsmap(d))
        eprint("Found %i BSMAP output files" % len(qsubs))

        # find all the appropriate BAM files
        bam_dict = {}
        for qsub in qsubs:
            # BSMAP says that the bam ends with "_r1.bam"
            # we remove the "_r1.bam" here and replace it with ".bam"
            outf = "".join([d, "/", qsub.sample_name, ".bam"])
            if os.path.isfile(outf):
                bam_dict[qsub] = BamFile(outf)
            else:
                search_failed = True
                eprint("Error: Missing BAM file '%s' corresponding with BSMAP file '%s'" % (outf, qsub.filename))
        eprint("Found %i BAM files" % len(bam_dict))

        # find all metrics files
        picard_dict = {}
        for qsub in qsubs:
            outf = "".join([d, "/", qsub.sample_name, "-metrics.txt"])
            if os.path.isfile(outf):
                picard_dict[qsub] = PicardMetrics(outf)
            else:
                search_failed = True
                eprint("Error: Missing Picard output file '%s' corresponding with BSMAP file '%s'" % (outf, qsub.filename))
        eprint("Found %i Picard output files" % len(picard_dict))

        # if any files cannot be found
        if search_failed:
            eprint("Aborting since we cannot find the file(s) above")
            exit(255)

        samples += [Sample(d, q, bam_dict[q], picard_dict[q]) for q in qsubs]

    samples.sort(key=lambda x: x.name)
    samples.sort(key=lambda x: x.dirname)
    for samp in samples:
        output.write(",".join(map(str, samp.row())) + "\n")


parser = argparse.ArgumentParser(description="Script for parsing read information in a directory.")
# parser.add_argument("--bam", nargs="+", metavar="FILE",
#                     help="BAM files to be included. If omitted, \
#                           target directory will be scanned.")
# parser.add_argument("--bsmap", nargs="+", metavar="FILE",
#                     help="BSMAP output files to be included. If omitted, \
#                     target directory will be scanned.")
# parser.add_argument("--picard", nargs="+", metavar="FILE",
#                     help="Picard output files to be included. If omitted, \
#                     target directory will be scanned.")
parser.add_argument("-o", "--output",
                    help="Specify an output file. If omitted, results will \
                    be written to stdout.")
parser.add_argument("dirs", nargs="*",
                    help="Targets to scan. If no targets are provided, the \
                          current directory is scanned.")
args = parser.parse_args()

if args.dirs:
    for d in args.dirs:
        if not os.path.exists(d):
            eprint("Error: directory '%s' does not exist" % d)
            exit(255)
        elif not os.path.isdir(d):
            eprint("Error: not a directory: '%s'" % d)
            exit(255)
    dirs = args.dirs
else:
    dirs = [os.getcwd()]

output = open(args.output, "w") if args.output else sys.stdout
main(dirs, output)
