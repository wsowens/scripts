#!/usr/bin/env python
'''Separates two FASTAs into two different files, based on sequence length of each record.'''
from Bio import SeqIO, Seq
from sys import argv
from os.path import splitext

def separate(file, threshold):
	below = []
	above = []
	recordList = SeqIO.parse(file, "fasta")
	for record in recordList:
		if len(record.seq) < threshold:
			below.append(record)
		else:
			above.append(record)
	return (below, above)

usage = """USAGE:
python fastasize.py [input.fa] [threshold]
"""
		
if __name__ == "__main__":
	#checking the number of arguments
	if len(argv) < 3:
		print("Error: exepected 2 arguments, received %s" % (len(argv)-1))
		print(usage)
		exit()
	
	#throws an error if argv[2] is not an int
	threshold = int(argv[2])
	basename = splitext(argv[1])[0]

	for arg in argv[1:len(argv)-1]:
		with open(arg, 'r') as file:
			lists = separate(file, threshold)
			SeqIO.write(lists[0], basename + "_below.fa", "fasta")			
			SeqIO.write(lists[1], basename + "_above.fa", "fasta")			
