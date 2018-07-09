#!/usr/bin/env python

import sys
for line in sys.stdin:
	f=line.strip().split()
### fastq require the qulity score either has no name or has same name of sequence	
	if f[0]=="+":
		print "+"
	else:
		print "".join(f)

