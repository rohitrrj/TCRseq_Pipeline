#!/usr/bin/env python

### trimed reads between 15-50 regins

import sys
from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator

f_file=sys.argv[1].split(".")[0]+"_1.fastq"
r_file=sys.argv[1].split(".")[0]+"_2.fastq"
f_out=open(f_file,"w")
r_out=open(r_file,"w")


for title,seq,qual in FastqGeneralIterator(open(sys.argv[1])):
        title_1=title[:len(title)/2]
	title_2=title[len(title)/2:]
	seq1=seq[:len(seq)/2-2]
	seq2=seq[(len(seq)/2-2+12):]
	qual1=qual[:len(seq)/2-2]
	qual2=qual[(len(seq)/2-2+12):]
	f_out.write("@%s\n%s\n+\n%s\n"%(title_1,seq1,qual1))
	r_out.write("@%s\n%s\n+\n%s\n"%(title_2,seq2,qual2))

f_out.close()
r_out.close()


