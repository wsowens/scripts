#!/usr/bin/env python
'''Warning, this module needs further testing

Copyright 2019 William Owens

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''
from __future__ import print_function
import sys


def eprint(*args):
    print(*args, file=sys.stderr)


class BedFile:
    '''Wrapper for an opened bed file
    In essence, the BED File is represented as a queue of lines
    Attributes:
        self.ifs = internal field separator
        self._filename = filename
        self._handle = file handle
        self.chr = chromosome of the current line
        self.start = start position of current line
        self.stop = stop position of current line
        self.lineno = number of lines processed
        self.has_next = true if unprocessed lines are remaining
        self.cols = containing each value in the column of the line
        self.col_count = number of columns
                        (not including the chr, start, and stop)
    Methods:
        self.next() = proceed to next line
 '''
    def __init__(self, filename, ifs="\t"):
        self.ifs = ifs
        self._filename = filename
        self._handle = open(filename)
        self.chr = None
        self.start = None
        self.stop = None
        self.cols = None
        self.lineno = 0
        self.has_next = True
        self.next()
        # if we have successfully loaded in the first line, this should succeed
        assert(self.cols is not None)
        # establishing the number of columns
        self.col_count = len(self.cols[3::])

    def next(self):
        '''get the next line in the BED'''
        try:
            current = next(self._handle)
        # exception thrown by an iterator if no remaining content
        except StopIteration:
            self.has_next = False
            return
        # increment number of lines processed
        self.lineno += 1
        # split the columns based on the internal field separator
        self.cols = current.strip().split(self.ifs)
        self.chr = self.cols[0]
        self.start = int(self.cols[1])
        self.stop = int(self.cols[2])

    def coords(self):
        '''Return a list containing the coordinates'''
        return [self.chr, str(self.start), str(self.stop)]

    def __eq__(self, other):
        '''returns true if this BED file is at same position as the other'''
        # TODO: check type of other
        return (self.chr == other.chr and self.start == other.start
                and self.stop == other.stop)

    def __gt__(self, other):
        '''Returns true if this BED file is ahead of the other BED file'''
        if self.chr > other.chr:
            return True
        elif self.chr < other.chr:
            return False
        return self.start > other.start

    def __del__(self):
        '''BED file is closed when wrapper falls out of scope'''
        self._handle.close()


# debugging variables
# This should be true:
# MERGE_COUNT + BED1_ONLY_COUNT + BED2_ONLY_COUNT = bed1.lineno + bed2.lineno
MERGE_COUNT = 0
BED1_ONLY_COUNT = 0
BED2_ONLY_COUNT = 0


def merge(bed1, bed2, zero="0"):
    global MERGE_COUNT, BED1_ONLY_COUNT, BED2_ONLY_COUNT
    while bed1.has_next and bed2.has_next:
        if bed1 == bed2:
            protoline = bed1.coords() + bed1.cols[3::] + bed2.cols[3::]
            bed1.next()
            bed2.next()
            MERGE_COUNT += 1
        elif bed1 > bed2:
            protoline = bed2.coords() + [zero] * bed1.col_count + bed2.cols[3::]
            bed2.next()
            BED2_ONLY_COUNT += 1
        else:
            protoline = bed1.coords() + bed1.cols[3::] + [zero] * bed2.col_count
            bed1.next()
            BED1_ONLY_COUNT += 1
        yield protoline
    while bed1.has_next:
        yield bed1.coords() + bed1.cols[3::] + [zero] * bed2.col_count
        bed1.next()
        BED1_ONLY_COUNT += 1
    while bed2.has_next:
        yield bed2.coords() + [zero] * bed1.col_count + bed2.cols[3::]
        bed2.next()
        BED2_ONLY_COUNT += 1


def main(filename1, filename2, output, ifs="\t", ofs="\t", ors="\n", zero="0", recipe=None):
    '''Combine two files, [filename1] and [filename2], into an output.'''
    bed1 = BedFile(filename1, ifs)
    bed2 = BedFile(filename2, ifs)
    if recipe is not None:
        for line in merge(bed1, bed2):
            line = recipe(line)
            # HARD CODING FOR SPEED
            if line[4] >= 10:
                output.write(ofs.join(line) + ors)
    else:
        for line in merge(bed1, bed2):
            output.write(ofs.join(line) + ors)
    # TODO: built-in coverage-checking feature
    eprint("bed1.lineno:\t%i" % bed1.lineno)
    eprint("bed2.lineno:\t%i" % bed2.lineno)
    eprint("total\t%i" % (bed1.lineno + bed2.lineno))


def bedpool(line, debug=False):
    '''properly combine two individual lines'''
    # the name of this function is a marvel reference
    total = int(line[4]) + int(line[7])
    unconverted = int(line[5]) + int(line[8])
    merged = ""
    if (line[4] != "0") and (line[6] != ""):
        merged = "merged"
    if debug:
        return [line[0], line[1], line[2], str(float(unconverted) / total), str(total), str(unconverted), line[4], line[5], line[7], line[8], merged]
    return [line[0], line[1], line[2], str(float(unconverted) / total), str(total), str(unconverted)]


usage = '''bedsync.py
Merge two bedfiles
=======
Usage:
bedsync.py file1 file2 output'''


if __name__ == "__main__":
    if len(sys.argv) < 3:
        eprint(usage)
        exit()
    elif len(sys.argv) == 3:
        main(sys.argv[1], sys.argv[2], sys.stdout, recipe=bedpool)
    else:
        output = open(sys.argv[3], 'w')
        main(sys.argv[1], sys.argv[2], output, recipe=bedpool)
        output.close()
    eprint("BED1_ONLY_COUNT:\t%i" % BED1_ONLY_COUNT)
    eprint("BED2_ONLY_COUNT:\t%i" % BED2_ONLY_COUNT)
    eprint("MERGE_COUNT:\t%i" % MERGE_COUNT)
    eprint("total\t%i" % (BED1_ONLY_COUNT + BED2_ONLY_COUNT + MERGE_COUNT * 2))
