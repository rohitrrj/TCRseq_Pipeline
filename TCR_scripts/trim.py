#!/usr/bin/env python

### trimed reads between 15-50 regins 


import gzip
import sys
from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator

start=int(sys.argv[2])
end=int(sys.argv[3])

for title,seq,qual in FastqGeneralIterator(open(sys.argv[1])):
        print "@%s\n%s\n+\n%s"% (title, seq[start:end], qual[start:end])
